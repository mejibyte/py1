class ListsController < ApplicationController

  before_filter :load_user

  def load_user
    if params[:user_id].nil?
      redirect_to '/'
    else
      @user = User.find(params[:user_id])
    end
  end

  # GET /lists
  # GET /lists.xml
  def index
    @lists = @user.lists

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @lists }
    end
  end

  # GET /lists/1
  # GET /lists/1.xml
  def show
    @list = @user.lists.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @list }
    end
  end

  # GET /lists/new
  # GET /lists/new.xml
  def new
    @list = @user.lists.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @list }
    end
  end

  # GET /lists/1/edit
  def edit
    @list = @user.lists.find(params[:id])
  end

  # POST /lists
  # POST /lists.xml
  def create
    @list = @user.lists.build(params[:list])
    @list.date = Time.now.advance(:hours=>-5)
    respond_to do |format|
      if @list.save
        flash[:notice] = 'La lista fue creada con éxito.'
        format.html { redirect_to([@user, @list]) }
        format.xml  { render :xml => @list, :status => :created, :location => @list }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @list.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /lists/1
  # PUT /lists/1.xml
  def update
    params[:list][:product_ids] ||= []
    @list = @user.lists.find(params[:id])

    respond_to do |format|
      if @list.update_attributes(params[:list])
        flash[:notice] = 'La lista se ha actualizado.'
        format.html { redirect_to([@user, @list] ) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @list.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /lists/1
  # DELETE /lists/1.xml
  def destroy
    @list = List.find(params[:id])
    @list.destroy

    respond_to do |format|
      format.html { redirect_to( user_path(@user) ) }
      format.xml  { head :ok }
    end
  end
end
