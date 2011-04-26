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
  
end
