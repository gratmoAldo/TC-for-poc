# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def text_field_for(form, field, 
                     size=HTML_TEXT_FIELD_SIZE, 
                     maxlength=DB_STRING_MAX_LENGTH)
    form_field = form.text_field field, :size => size, :maxlength => maxlength
    content_tag("tr", content_tag("td", "#{field.humanize}", :class => 'label') + content_tag("td", "#{form_field}"))
  end
  def text_area_for(form, field)
    form_field = form.text_area field
    content_tag("tr", content_tag("td", "#{field.humanize}", :class => 'label') + content_tag("td", "#{form_field}"))
  end

  def how_old(seconds=0, options={})
    options.reverse_merge! :format => :short, :ago => false
    ago = options[:ago] ? " ago" : ""
    if options[:format] == :short
      format = { :minute => "min", :hour => "hour", :hours => "hrs", :day => "day", :month => "month", :months => "mos"}
    else
      format = { :minute => "minutes", :hour => "hour", :hours => "hours", :day => "day", :month => "month", :months => "months"}
    end

    if seconds < 60 then # 1 minute
      "just now"
    else
      if seconds < 3600 then # 1 hour
        pluralize((seconds / 60), format[:minute]) + ago
      elsif seconds < 172800 then # 2 days
        pluralize((seconds / 3600), format[:hour], format[:hours]) + ago
      elsif seconds < 2635200 then # 30 days
        pluralize((seconds / 86400), format[:day]) + ago
      else
        pluralize((seconds / 2635200), format[:month], format[:months]) + ago
      end
    end
  end

  
end
