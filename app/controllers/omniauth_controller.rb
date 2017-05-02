class OmniauthController < ApplicationController
  def google_redirect
    return_url = params[:return_url]

    auth_url = user_google_oauth2_omniauth_authorize_path
    auth_url += "?" + URI.encode_www_form(state: URI.encode_www_form(:return_url => return_url))
    redirect_to auth_url
  end

  def google_oauth2
    state = Hash.new
    params_state = params['state']
    if params_state && params_state.length
      state = Hash[URI::decode_www_form(params_state)]
    end

    auth = request.env["omniauth.auth"]
    user = User.find_by(email: auth.info.email)

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
        calendar = GoogleCalendarWrapper.new(auth.credentials.token, auth.credentials.refresh_token)
        raise Signet::AuthorizationError.new unless calendar.token_enable?

        if user
          user.image = auth.info.image
          user.update_credentials!(auth.credentials.token, auth.credentials.refresh_token)
        else
          user = User.insert!(auth.info.email, auth.info.image, auth.credentials.token, auth.credentials.refresh_token)
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

          text = line_room.line_room_talks.build(text: line.text)
          text.save!

          if /[?&]id=(?<identifier>[^&]+)/ =~ line.text
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
            event = Event.parse_from_text(line.text)
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
        redirect_to return_url.append_query(code: 'EUSR0001')
      else
        render :json => { status: 400, message: 'authorization failed' }
      end
    end

    def request_body
      env["rack.input"].try(:read) || request.body.string
    end
end
