require 'google/api_client/client_secrets'
require 'google/apis/oauth2_v2'

class OmniauthController < ApplicationController
  def google_redirect
    return_url = params[:return_url]

    client_secrets = Google::APIClient::ClientSecrets.new(
      web: {
        client_id: Settings.google.client_id,
        client_secret: Settings.google.client_secret,
      }
    )
    auth_client = client_secrets.to_authorization
    auth_client.update!(
      :scope => Settings.google.scope.split(','),
      :redirect_uri => "#{Settings.app.full_host}/omniauth/google_callback",
      :additional_parameters => {
        "access_type" => "offline",
        "include_granted_scopes" => "true"
      },
      :state => URI.encode_www_form(:return_url => return_url)
    )

    auth_uri = auth_client.authorization_uri.to_s
    redirect_to auth_client.authorization_uri.to_s
  end

  def google_callback
    state = Hash.new
    params_state = params['state']
    if params_state && params_state.length
      state = Hash[URI::decode_www_form(params_state)]
    end

    client_secrets = Google::APIClient::ClientSecrets.new(
      web: {
        client_id: Settings.google.client_id,
        client_secret: Settings.google.client_secret,
      }
    )
    auth_client = client_secrets.to_authorization
    auth_client.update!(
      :scope => Settings.google.scope.split(','),
      :redirect_uri => "#{Settings.app.full_host}/omniauth/google_callback",
      :code => params['code']
    )
    auth_client.fetch_access_token!

    oauth2 = Google::Apis::Oauth2V2::Oauth2Service.new
    oauth2.authorization = auth_client
    user_info = oauth2.get_userinfo

    user = User.find_by(email: user_info.email)

    success = false
    if user
      begin
        calendar = GoogleCalendarWrapper.new(user.token, user.refresh_token)
        success = calendar.token_enable?
      rescue Signet::AuthorizationError => e
        # none
      end
    end

    unless success
      begin
        calendar = GoogleCalendarWrapper.new(auth_client.access_token, auth_client.refresh_token)
        raise Signet::AuthorizationError.new unless calendar.token_enable?

        if user
          user.image = user_info.picture
          user.update_credentials!(auth_client.access_token, auth_client.refresh_token)
        else
          user = User.insert!(user_info.email, user_info.picture, auth_client.access_token, auth_client.refresh_token)
        end
      rescue Signet::AuthorizationError => e
        failed(state) and return
      end
    end

    if state['return_url']&.is_url?
      return_url = state['return_url']
      redirect_to return_url.append_query(token: user.generate_token)
    else
      render :json => { status: 200, message: 'ok' }
    end
  end

  def line_callback
    LineBotWrapper.parse_each(request_body, request.headers['HTTP_X_LINE_SIGNATURE']) do |line|
      begin
        case line.type
        when Line::Bot::Event::MessageType::Text
          line_room = LineRoom.find_or_initialize_by(line_me_room_id: line.room_id)
          line_room.save!

          text = text.utf8mb4_encode
          talk = line_room.line_room_talks.build(text: line.text)
          talk.save!

          if /[?&]id=(?<identifier>[^&]+)/ =~ text
            user = User.analyze_identifier(identifier)
            if user.present?
              calendar_wrapper = GoogleCalendarWrapper.new(user.token, user.refresh_token)
              if line_room.users.find_by(id: user.id).blank?
                calendar_result = calendar_wrapper.insert_calendar(line.room_id)
                calendar = Calendar.insert_or_update!(calendar_result)
                line_room_calendar_relation = LineRoomCalendarRelation.new(line_room_id: line_room.id, calendar_id: calendar.id)
                line_room_calendar_relation.save!
                line_room.reload

                user_calendars_relation = UserCalendarsRelation.new(user_id: user.id, calendar_id: calendar.id)
                user_calendars_relation.save!

                line.reply_message('カレンダーを作成しました。')
              else
                line.reply_message('カレンダーは作成済みです。')
              end
            end
          end

          if line_room.calendars.present?
            event = Event.parse_from_text(text)
            if event.present?
              line_room.calendars.each do |calendar|
                user = calendar.user
                calendar_wrapper = GoogleCalendarWrapper.new(user.token, user.refresh_token)
                event_result = calendar_wrapper.insert_event(calendar.google_calendar_id, event.to_h)
                event.calendar_id = calendar.id
                event.google_event_id = event_result[:id]
                event.save!
              end
            end
          end
        end
      rescue => e
        Rails.logger.warn e
      end
    end

    render :json => { status: 200, message: 'ok' }
  end

  private
    def failed(state)
      if state['return_url']&.is_url?
        return_url = state['return_url']
        redirect_to return_url.append_query(error: 'invalid_authenticity')
      else
        render :json => { status: 400, message: 'authorization failed' }
      end
    end

    def request_body
      env["rack.input"].try(:read) || request.body.string
    end
end
