class Address
  include ActiveModel::Model
  attr_accessor :street, :city, :state, :zip, :type
end
