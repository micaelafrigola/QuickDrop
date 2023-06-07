class OrdersController < ApplicationController

  before_action :set_order, only: %i[show specialshow edit update]
  before_action :set_submitted_order, only: %i[accept markascompleted cancel]
  def index
    @orders = policy_scope(Order)
  end

  def new
    @order = Order.new
    authorize @order
  end

  def show
  end


  def specialshow
  end


  def create
    @order = Order.new(order_params)
    @order.user = current_user
    authorize @order
    respond_to do |format|
      if @order.save
        format.html { redirect_to edit_order_path(@order) }
        format.json { render :show, status: :created, location: @order }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    if @order.update(order_params)
      redirect_to order_path(@order)   # redirect_to @order
    else
      render :edit
    end
  end

  def accept
    @order.update(status: "Accepted")
    redirect_to order_path(@order)
    # redirect_to orders_path, notice: "order accepted!"
  end

  def markascompleted
    @order.update(status: "Completed")
    redirect_to order_path(@order)
    # redirect_to orders_path, notice: "order completedd!"
  end

  def cancel
    @order.update(status: "Cancaled")
    redirect_to order_path(@order)
    # redirect_to orders_path, notice: "order canceled!"
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
    params.require(:order).permit(:item_description, :item_size, :status, :pickup_name, :pickup_address, :pickup_contact_phone, :pickup_additional_detail, :pickup_at, :dropoff_name, :dropoff_address, :dropoff_contact_phone, :dropoff_additional_detail, :dropoff_at, :price, :distance )
  end


end
