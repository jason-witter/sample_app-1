# 508 Compliance and Agile

### Education

The first step in creating an application that is 508 compliant is understanding what makes a truly 508 compliant website. Too often software development teams are only superficially aware of the requirements for 508 compliance and as a result, only recognize and address problems of a relatively narrow scope. Examples could include adjusting the hue of a field label to maintain contrast ratios or adding alt text to images. To remedy this surface level 508 understanding, teams are encouraged to dedicate at least one resource to taking a deeper dive into 508 compliance. Ideally, this resource would become a certified 508 tester, but the process of acquiring more in depth 508 knowledge in general is useful to the team as a whole. An appreciation and understanding of the details of 508 somewhat counter-intuitively allows the team to view the 508 compliance of the application in a larger context. Once teams are seeing 508 compliance at the application level instead of on a page by page basis, there should be a natural evolution to the way code is written.

### Consistency and Reusability

A hallmark of an application that consistently maintains 508 compliance is the creation and maintenance of a code library where all of the components are already 508 compliant. This library should include common form patterns, screen elements like headers and footers, and common CSS stylesheets. A highly recommended extension of this code library is a style guide. This style guide serves as a place to display things like color palettes, inputs, backgrounds and all of the other common pieces of code that can be used within an application. The major advantage that results from devoting time to the establishment and cultivation of this compliant code library is that developers can use them throughout the application with a high degree of certainty that they aren't introducing any new compliance issues. The code library, properly implemented, can also provide a central place to make changes which then propogate throughout the application.

### Foundation, not Patchwork

By applying progressive enhancement with a focus on 508 compliance, teams can make sure that compliance is baked into the application at the most basic levels. In this context, progressive enhancement means beginning with HTML, moving on to mixing in CSS, and then finally utilizing Javascript to drive interactions with the application. Building the application in this way helps decrease the severity of two of the most difficult 508 requirements; that the site must be functional with CSS and Javascript turned off.

### Technical

Most programming languages include html templating libraries and helpers. Rails for example has their [FormBuilder](http://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html). By extending the FormBuilder and customizing the templating helpers it is possible to have consistency and allow developers to easily enhance and make changes to the html across an entire application.

We're going to use a very basic address form. We'll have some address inputs and some radio buttons to specify the type of address it is.

```ruby
# views/address/new.html.erb

<%= form_for Address.new, url: { action: "create" } do |f| %>
  <%= f.collection_radio_buttons :type, [['billing', 'Billing Address'] ,['mailing', 'Mailing Address']], :first, :last %>
  <%= f.text_field :street %>
  <%= f.text_field :city %>
  <%= f.text_field :state %>
  <%= f.text_field :zip %>
<% end %>
```

```html
<form class="new_address" id="new_address" action="/create" accept-charset="UTF-8" method="post" _lpchecked="1">
  <input name="utf8" type="hidden" value="✓">
  <input type="hidden" name="authenticity_token" value="VVMX2CXRHSrKSO0Tu9Wpxn/OyAtxHPy7kb5pmfqzjUpxSkNHtxcMuSilrXsbK7NoLjf7nkUGr75qbOTambPJ6w==">

  <input type="radio" value="billing" name="address[type]" id="address_type_billing"><label for="address_type_billing">Billing Address</label><input type="radio" value="mailing" name="address[type]" id="address_type_mailing"><label for="address_type_mailing">Mailing Address</label>

  <input type="text" name="address[street]" id="address_street">
  <input type="text" name="address[city]" id="address_city">
  <input type="text" name="address[state]" id="address_state">
  <input type="text" name="address[zip]" id="address_zip">
</form>
```

However, from a 508 perspective there's a number of things wrong here.
  - All the inputs need labels
  - Associated radio buttons require fieldsets
  - Corresponding name/description for the related radio buttons should go in the legend

To fix this we could do something like this:

```ruby
# views/address/new.html.erb

<%= form_for Address.new, url: { action: "create" } do |f| %>
  <%= content_tag(:fieldset) do %>
    <%= content_tag(:legend, 'Type') %>
    <%= f.collection_radio_buttons :type, [['billing', 'Billing Address'] ,['mailing', 'Mailing Address']], :first, :last %>
  <%= end %>

  <%= f.label :street %>
  <%= f.text_field :street %>

  <%= f.label :city %>
  <%= f.text_field :city %>

  <%= f.label :state %>
  <%= f.text_field :state %>

  <%= f.label :zip %>
  <%= f.text_field :zip %>
<% end %>
```

```html
<form class="new_address" id="new_address" action="/create" accept-charset="UTF-8" method="post">
  <input name="utf8" type="hidden" value="✓">
  <input type="hidden" name="authenticity_token" value="xShi7mTqSj7hrJzlOQnrY2a+V4UW25gautZ7KFrU2hvhMTZx9ixbrQNB3I2Z9/HNN0dkECLByx9BBPZrOdSeug==">

  <fieldset>
    <legend>Type</legend>
    <input type="radio" value="billing" name="address[type]" id="address_type_billing"><label for="address_type_billing">Billing Address</label>
    <input type="radio" value="mailing" name="address[type]" id="address_type_mailing"><label for="address_type_mailing">Mailing Address</label>
  </fieldset>

  <label for="address_street">Street</label>
  <input type="text" name="address[street]" id="address_street">

  <label for="address_city">City</label>
  <input type="text" name="address[city]" id="address_city">

  <label for="address_state">State</label>
  <input type="text" name="address[state]" id="address_state">

  <label for="address_zip">Zip</label>
  <input type="text" name="address[zip]" id="address_zip">
</form>
```

We begin to see some redundancy. It would be nice if we could go back to the original form setup that took care of all of these details behind the scenes.
We can extend the rails form builder to do just that. This also means the developer doens't need to keep track of all the different nuances, it's all built in.


# Create the formbuilder


```ruby
# lib/forms/custom_builder.rb

class CustomFormBuilder < ActionView::Helpers::FormBuilder
end
```

Using our new form builder with the previous form:

```ruby
# views/address/new.html.erb

<%= form_for Address.new, url: { action: "create" }, builder: CustomFormBuilder do |f| %>
  <%= content_tag(:fieldset) do %>
    <%= content_tag(:legend, 'Type') %>
    <%= f.collection_radio_buttons :type, [['billing', 'Billing Address'] ,['mailing', 'Mailing Address']], :first, :last %>
  <%= end %>

  <%= f.label :street %>
  <%= f.text_field :street %>

  <%= f.label :city %>
  <%= f.text_field :city %>

  <%= f.label :state %>
  <%= f.text_field :state %>

  <%= f.label :zip %>
  <%= f.text_field :zip %>
<% end %>
```

The form produced is identical to the previous one.

```html
<form class="new_address" id="new_address" action="/create" accept-charset="UTF-8" method="post">
  <input name="utf8" type="hidden" value="✓">
  <input type="hidden" name="authenticity_token" value="xShi7mTqSj7hrJzlOQnrY2a+V4UW25gautZ7KFrU2hvhMTZx9ixbrQNB3I2Z9/HNN0dkECLByx9BBPZrOdSeug==">

  <fieldset>
    <legend>Type</legend>
    <input type="radio" value="billing" name="address[type]" id="address_type_billing"><label for="address_type_billing">Billing Address</label>
    <input type="radio" value="mailing" name="address[type]" id="address_type_mailing"><label for="address_type_mailing">Mailing Address</label>
  </fieldset>

  <label for="address_street">Street</label>
  <input type="text" name="address[street]" id="address_street">

  <label for="address_city">City</label>
  <input type="text" name="address[city]" id="address_city">

  <label for="address_state">State</label>
  <input type="text" name="address[state]" id="address_state">

  <label for="address_zip">Zip</label>
  <input type="text" name="address[zip]" id="address_zip">
</form>
```

The difference is that we can now make customizations in two places. In the view and in the form builder itself

This provides us with a few benefits:
The builder will take care of the html consistancy and all the underlying 508 requirements
The view, will be used to tell the builder what to build

Take line 6 and 7 from `views/address/new.html.erb.`

```ruby
<%= f.label :street %>
<%= f.text_field :street %>
```

This produced the street input with a label because 508 requires all inputs to have labels describing them. Let's see how we can leverage the form builder to take care of this for us.

```ruby
# lib/forms/my_form_builder.rb

class CustomFormBuilder < ActionView::Helpers::FormBuilder
  def text_field(method, options={})
    label(:method)
    super(method, options)
  end
end
```

Now we can make the same for like this:

```ruby
# views/address/new.html.erb

<%= form_for Address.new, url: { action: "create" }, builder: CustomFormBuilder do |f| %>
  <%= content_tag(:fieldset) do %>
    <%= content_tag(:legend, 'Type') %>
    <%= f.collection_radio_buttons :type, [['billing', 'Billing Address'] ,['mailing', 'Mailing Address']], :first, :last %>
  <%= end %>

  <%= f.text_field :street %>
  <%= f.text_field :city %>
  <%= f.text_field :state %>
  <%= f.text_field :zip %>
<% end %>
```

```html
<form class="new_address" id="new_address" action="/create" accept-charset="UTF-8" method="post">
  <input name="utf8" type="hidden" value="✓">
  <input type="hidden" name="authenticity_token" value="xShi7mTqSj7hrJzlOQnrY2a+V4UW25gautZ7KFrU2hvhMTZx9ixbrQNB3I2Z9/HNN0dkECLByx9BBPZrOdSeug==">

  <fieldset>
    <legend>Type</legend>
    <input type="radio" value="billing" name="address[type]" id="address_type_billing"><label for="address_type_billing">Billing Address</label>
    <input type="radio" value="mailing" name="address[type]" id="address_type_mailing"><label for="address_type_mailing">Mailing Address</label>
  </fieldset>

  <label for="address_street">Street</label>
  <input type="text" name="address[street]" id="address_street">

  <label for="address_city">City</label>
  <input type="text" name="address[city]" id="address_city">

  <label for="address_state">State</label>
  <input type="text" name="address[state]" id="address_state">

  <label for="address_zip">Zip</label>
  <input type="text" name="address[zip]" id="address_zip">
</form>
```

Now we can also take care of the collection_radio_buttons needing a fieldset by adding another method to our form builder:

```ruby
# lib/forms/custom_form_builder.rb

class CustomFormBuilder < ActionView::Helpers::FormBuilder
  def text_field(method, options={})
    input = label(:method)
    input << super(method, options)
    input
  end

  def collection_radio_buttons(method, collection, value_method, text_method, options = {}, html_options = {})
    @template.content_tag(:fieldset) do
      input = @template.content_tag(:legend, method.to_s.titleize)
      input << super(method, collection, value_method, text_method, options, html_options)
      input
    end
  end
end
```

And our new form:

```ruby
# views/address/new.html.erb

<%= form_for Address.new, url: { action: "create" }, builder: CustomFormBuilder do |f| %>
  <%= f.collection_radio_buttons :type, [['billing', 'Billing Address'] ,['mailing', 'Mailing Address']], :first, :last %>
  <%= f.text_field :street %>
  <%= f.text_field :city %>
  <%= f.text_field :state %>
  <%= f.text_field :zip %>
<% end %>
```

Because we have a single place we're making changes to the inputs we can easily add more customizations. Let's say for example  we wanted to add inline input errors for all fields. If we were still using our original form without the input builder we might start by doing something like this:

```ruby
# views/address/new.html.erb

<%= form_for Address.new, url: { action: "create" }, builder: CustomFormBuilder do |f| %>
  <%= content_tag(:fieldset) do %>
    <%= content_tag(:legend, 'Type') %>
    <%= f.collection_radio_buttons :type, [['billing', 'Billing Address'] ,['mailing', 'Mailing Address']], :first, :last %>
    <%= content_tag(:span, f.errors[:method].first) if f.errors[:method].present? %>
  <%= end %>

  <%= f.label :street %>
  <%= f.text_field :street %>
  <%= content_tag(:span, f.errors[:method].first) if f.errors[:method].present? %>

  <%= f.label :city %>
  <%= f.text_field :city %>
  <%= content_tag(:span, f.errors[:method].first) if f.errors[:method].present? %>

  <%= f.label :state %>
  <%= f.text_field :state %>
  <%= content_tag(:span, f.errors[:method].first) if f.errors[:method].present? %>

  <%= f.label :zip %>
  <%= f.text_field :zip %>
  <%= content_tag(:span, f.errors[:method].first) if f.errors[:method].present? %>
<% end %>
```

However we've created another problem for 508. Errors also need to be associated with the input they're showing for. One of the most compatible ways to do this is to surround the input and error with the label tag like so:

```ruby
# views/address/new.html.erb

<%= form_for Address.new, url: { action: "create" } do |f| %>
  <%= content_tag(:fieldset) do %>
    <%= content_tag(:legend, 'Type') %>
    <%= f.collection_radio_buttons :type, [['billing', 'Billing Address'] ,['mailing', 'Mailing Address']], :first, :last %>
    <%= content_tag(:span, f.errors[:method].first) if f.errors[:method].present? %>
  <%= end %>

  <%= f.label :street do %>
    <%= f.text_field :street %>
    <%= content_tag(:span, f.errors[:method].first) if f.errors[:method].present? %>
  <% end %>

  <%= f.label :city do %>
    <%= f.text_field :city %>
    <%= content_tag(:span, f.errors[:method].first) if f.errors[:method].present? %>
  <% end %>

  <%= f.label :state do %>
    <%= f.text_field :state %>
    <%= content_tag(:span, f.errors[:method].first) if f.errors[:method].present? %>
  <% end %>

  <%= f.label :zip do %>
    <%= f.text_field :zip %>
    <%= content_tag(:span, f.errors[:method].first) if f.errors[:method].present? %>
  <% end %>
<% end %>
```

```html
<form class="new_address" id="new_address" action="/create" accept-charset="UTF-8" method="post" _lpchecked="1">
  <input name="utf8" type="hidden" value="✓">
  <input type="hidden" name="authenticity_token" value="tRSBbSviPWZf8aoDGDSgvgmdOtQgJ2XgvyqMzPTOyEkvsbUgseGMXrV2km1T8e/9voK3r0r2CcInpbWFhPbKoA==">

  <fieldset>
    <legend class="legend-text">Type</legend>
    <input type="radio" value="billing" name="address[type]" id="address_type_billing"><label for="address_type_billing">Billing Address</label>
    <input type="radio" value="mailing" name="address[type]" id="address_type_mailing"><label for="address_type_mailing">Mailing Address</label>
  </fieldset>

  <label for="address_street">
    <span class="label-text">Street</span>
    <input type="text" name="address[street]" id="address_street">
  </label>

  <label for="address_city">
    <span class="label-text">City</span>
    <input type="text" name="address[city]" id="address_city">
  </label>

  <label for="address_state">
    <span class="label-text">State</span>
    <input type="text" name="address[state]" id="address_state">
  </label>

  <label for="address_zip">
    <span class="label-text">Zip</span>
    <input type="text" name="address[zip]" id="address_zip">
  </label>
</form>
```

Again, a lot of work and repitition, which opens up a lot of opportunities for mistakes. Let's go back to our form builder and take care of this there.

```ruby
# lib/forms/custom_form_builder.rb

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
```

Just a couple of changes in one place and we can go back to our cleaner form that produces the same markup.

```ruby
# views/address/new.html.erb

<%= form_for Address.new, url: { action: "create" }, builder: CustomFormBuilder do |f| %>
  <%= f.collection_radio_buttons :type, [['billing', 'Billing Address'] ,['mailing', 'Mailing Address']], :first, :last %>
  <%= f.text_field :street %>
  <%= f.text_field :city %>
  <%= f.text_field :state %>
  <%= f.text_field :zip %>
<% end %>
```

```html
<form class="new_address" id="new_address" action="/create" accept-charset="UTF-8" method="post" _lpchecked="1">
  <input name="utf8" type="hidden" value="✓">
  <input type="hidden" name="authenticity_token" value="tRSBbSviPWZf8aoDGDSgvgmdOtQgJ2XgvyqMzPTOyEkvsbUgseGMXrV2km1T8e/9voK3r0r2CcInpbWFhPbKoA==">

  <fieldset>
    <legend class="legend-text">Type</legend>
    <input type="radio" value="billing" name="address[type]" id="address_type_billing"><label for="address_type_billing">Billing Address</label>
    <input type="radio" value="mailing" name="address[type]" id="address_type_mailing"><label for="address_type_mailing">Mailing Address</label>
  </fieldset>

  <label for="address_street">
    <span class="label-text">Street</span>
    <input type="text" name="address[street]" id="address_street">
  </label>

  <label for="address_city">
    <span class="label-text">City</span>
    <input type="text" name="address[city]" id="address_city">
  </label>

  <label for="address_state">
    <span class="label-text">State</span>
    <input type="text" name="address[state]" id="address_state">
  </label>

  <label for="address_zip">
    <span class="label-text">Zip</span>
    <input type="text" name="address[zip]" id="address_zip">
  </label>
</form>
```
