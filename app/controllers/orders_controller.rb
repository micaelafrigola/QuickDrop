class OrdersController < ApplicationController

  before_action :set_order, only: %i[ show specialshow edit update ]
  before_action :set_submitted_order, only: %i[ accept markascompleted cancel]

  def index #customer
    # @order.user = current_user
    @orders = policy_scope(Order).where(customer_id: current_user.id).order(created_at: :desc)
  end

  def driverindex
    if current_user.driver?
      @orders = policy_scope(Order).where(status: "Pending").order(pickup_at: :asc)
    else
      redirect_to orders_path, alert: "No"
    end
  end

  def new
    @order = Order.new
    authorize @order
  end

  def show
    @marker1 =
      {
        lat: @order.pickup_latitude,
        lng: @order.pickup_longitude
      }
    @marker2 =
      {
        lat: @order.dropoff_latitude,
        lng: @order.dropoff_longitude
      }
    @markers = [@marker1, @marker2]
  end


  def specialshow
  end


  def create
    @order = Order.new(order_params)
    @order.customer_id = current_user.id
    authorize @order
    respond_to do |format|
      if @order.save
        format.html { redirect_to edit_order_path(@order) }
        format.json { render :edit, status: :created, location: @order }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @order.update(order_params)
        @order.calculate_distance
        @order.calculate_price
        @order.trip_duration
        @order.dropoff_time
        @order.save!
        format.html { redirect_to order_path(@order) }
        format.json { render :show }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end

  end

  def accept
    @order.update(status: "Accepted")
    @order.driver_id = current_user.id
    @order.save!
    redirect_to order_path(@order)
    # redirect_to orders_path, notice: "order accepted!"
  end

  def markascompleted
    @order.update(status: "Completed")
    @order.save!
    redirect_to driverindex_path

    # redirect_to orders_path, notice: "order completed!"
  end

  def cancel
    @order.update(status: "Cancelled")
    @order.save!
    redirect_to orders_path
  end

  private


  def set_order
    @order = Order.find(params[:id])
    authorize @order
  end

  def set_submitted_order
    @order = Order.find(params[:order_id])
    authorize @order
  end

  def order_params
    params.require(:order).permit(:item_description, :item_size, :status, :pickup_name, :pickup_address, :pickup_contact_phone, :pickup_additional_detail, :pickup_at, :dropoff_name, :dropoff_address, :dropoff_contact_phone, :dropoff_additional_detail, :dropoff_at, :price,
    :distance, :duration)
  end

end
