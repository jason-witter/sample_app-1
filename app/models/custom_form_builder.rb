class CustomFormBuilder < ActionView::Helpers::FormBuilder
  def text_field(method, options={})
    label(method) do
      input = @template.content_tag(:span, method.to_s.titleize, class: 'label-text')
      input << super(method, options)
      input << @template.content_tag(:span, object.errors[:method].first, class: 'error-text') if object.errors[:method].present?
      input
    end
  end

  def collection_radio_buttons(method, collection, value_method, text_method, options = {}, html_options = {})
    @template.content_tag(:fieldset) do
      input = @template.content_tag(:legend, method.to_s.titleize, class: 'legend-text')
      input << super(method, collection, value_method, text_method, options, html_options)
      input << @template.content_tag(:span, object.errors[:method].first, class: 'error-text') if object.errors[:method].present?
      input
    end
  end
end
