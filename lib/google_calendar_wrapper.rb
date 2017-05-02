require 'open-uri'
require 'google/apis/calendar_v3'
class GoogleCalendarWrapper
  MAX_RETRY_COUNT = Settings[:retry_count]
  INITIAL_TOKEN = :initial_token

  def initialize(token, refresh_token)
    authorization = Signet::OAuth2::Client.new
    authorization.access_token = token
    authorization.refresh_token = refresh_token
    authorization.token_credential_uri = 'https://accounts.google.com/o/oauth2/token'
    authorization.audience = 'https://accounts.google.com/o/oauth2/token'
    authorization.client_id = Settings[:google][:client_id]
    authorization.client_secret = Settings[:google][:client_secret]
    authorization.scope = Settings[:google][:scope]

    @service = Google::Apis::CalendarV3::CalendarService.new
    @service.authorization = authorization
  end

  def token_enable?
    calendar_lists do |calendar|
      return true
    end

    false
  end

  def calendar_lists
    parameters = {
      :min_access_role => 'reader',
      :show_deleted => false,
      :show_hidden => false,
    }

    call_list(@service.method(:list_calendar_lists), parameters) do |item|
      hashed_item = {
        :id => item.id,
        :summary => item.summary,
        :description => item.description,
        :color_id => item.color_id,
        :background_color => item.background_color,
        :foreground_color => item.foreground_color,
        :access_role => item.access_role,
        :selected => item.selected,
        :time_zone => item.time_zone,
      }

      yield hashed_item
    end
  end

  def insert_calendar(summary)
    calendar = Google::Apis::CalendarV3::Calendar.new(
      summary: summary,
    )

    result = call_api(@service.method(:insert_calendar), calendar)
    {
      id: result.id,
      summary: result.summary,
    }
  end

  def share_to_email(calendar_id, email)
    rule = Google::Apis::CalendarV3::AclRule.new(
      scope: {
        type: 'user',
        value: email,
      },
      role: 'reader'
    )
    call_api(@service.method(:insert_acl), calendar_id, rule)
  end

  def events(calendar_id)
    parameters = {
      :time_max => (Time.zone.now + 1.year).strftime('%Y-%m-%dT%H:%M:%SZ'),
      :time_min => (Time.zone.now - 3.year).strftime('%Y-%m-%dT%H:%M:%SZ'),
      :max_results => 2500,
    }

    call_list_with_calendar_id(@service.method(:list_events), calendar_id, parameters) do |item|
      yield event_to_hash(item)
    end
  end

  def insert_event(calendar_id, hash)
    event = Google::Apis::CalendarV3::Event.new(
      summary: hash[:summary],
      location: hash[:location],
      description: hash[:description],
      start: {
        date_time: hash[:start].strftime('%Y-%m-%dT%H:%M:%S'),
        time_zone: 'UTC',
      },
      end: {
        date_time: hash[:end].strftime('%Y-%m-%dT%H:%M:%S'),
        time_zone: 'UTC',
      },
    )

    result = call_api(@service.method(:insert_event), calendar_id, event)
    event_to_hash(result)
  end

  def call_list_with_calendar_id(method, calendar_id, parameters)
    page_token = INITIAL_TOKEN
    parameters.delete(:page_token)

    while page_token
      if page_token && page_token != INITIAL_TOKEN
        parameters[:page_token] = page_token
      end

      search_response = call_api(method, calendar_id, parameters)
      search_response.items.each do |item|
        yield item
      end

      begin
        if search_response.items.length > 0
          page_token = search_response.next_page_token
        else
          page_token = nil
        end
      rescue
        page_token = nil
      end
    end
  end

  def call_list(method, parameters)
    page_token = INITIAL_TOKEN
    parameters.delete(:page_token)

    while page_token
      if page_token && page_token != INITIAL_TOKEN
        parameters[:page_token] = page_token
      end

      search_response = call_api(method, parameters)
      search_response.items.each do |item|
        yield item
      end

      begin
        if search_response.items.length > 0
          page_token = search_response.next_page_token
        else
          page_token = nil
        end
      rescue
        page_token = nil
      end
    end
  end

  def call_api(method, *args)
    search_response = nil
    retry_count = 0

    begin
      search_response = method.call(*args)
    rescue Google::Apis::ClientError => e
      if e.status_code >= 500 && e.status_code < 600 && retry_count < MAX_RETRY_COUNT
        Rails.logger.warn e.body
        retry_count += 1
        retry
      else
        raise e
      end
    rescue => e
      if retry_count < MAX_RETRY_COUNT
        Rails.logger.warn e
        retry_count += 1
        retry
      else
        raise e
      end
    end

    search_response
  end

  def event_to_hash(item)
    hashed_item = {
      :id => item.id,
      :summary => item.summary,
      :description => item.description,
      :color_id => item.color_id,
      :location => item.location,
    }
    hashed_item[:organizer] = item.organizer&.display_name
    hashed_item[:time_zone] = item.start&.time_zone
    hashed_item[:start] = item.start&.date_time
    hashed_item[:start] = item.start&.date if hashed_item[:start].blank?
    hashed_item[:end] = item.end&.date_time
    hashed_item[:end] = item.end&.date if hashed_item[:end].blank?
    hashed_item
  end

end
