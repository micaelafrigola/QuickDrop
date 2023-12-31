class Order < ApplicationRecord
  belongs_to :customer, class_name: "User"
  belongs_to :driver, class_name: "User", optional: true

  validates :pickup_address, presence: true
  validates :pickup_at, presence: true
  validates :dropoff_address, presence: true

  validate :check_address

  geocoded_by :pickup_address, latitude: :pickup_latitude, longitude: :pickup_longitude
  after_validation :geocode_pickup_location, if: :pickup_address_changed?

  geocoded_by :dropoff_address, latitude: :dropoff_latitude, longitude: :dropoff_longitude
  after_validation :geocode_dropoff_location, if: :dropoff_address_changed?

  validates :pickup_name, presence: true, on: :update
  validates :dropoff_name, presence: true, on: :update
  validates :item_size, presence: true, on: :update
  validates :dropoff_contact_phone, presence: true, on: :update
  validates :pickup_contact_phone, presence: true, on: :update

  before_create :calculate_distance, :calculate_price, :trip_duration, :dropoff_time


  SIZES = ['Small', 'Medium', 'Large']

  def check_address
    errors.add(:dropoff_address, "can't be the same as pick up address") if pickup_address == dropoff_address
  end

  def calculate_price
    self.price = (calculate_distance * 5.0).round(2)
  end

  def calculate_distance
    if pickup_latitude && pickup_longitude && dropoff_latitude && dropoff_longitude
      self.distance = Geocoder::Calculations.distance_between([pickup_latitude, pickup_longitude], [dropoff_latitude, dropoff_longitude]).round(2)
    end
  end

  def trip_duration
    speed = 7.0
    duration = calculate_distance / speed
    self.duration = ActiveSupport::Duration.build(duration.hours.round)
  end

  def dropoff_time
    self.dropoff_at = (pickup_at + trip_duration)
  end

  private

  def geocode_pickup_location
    geocoded = Geocoder.search(pickup_address).first
    if geocoded
      self.pickup_latitude = geocoded.latitude
      self.pickup_longitude = geocoded.longitude
    end
  end

  def geocode_dropoff_location
    geocoded = Geocoder.search(dropoff_address).first
    if geocoded
      self.dropoff_latitude = geocoded.latitude
      self.dropoff_longitude = geocoded.longitude
    end
  end
end
