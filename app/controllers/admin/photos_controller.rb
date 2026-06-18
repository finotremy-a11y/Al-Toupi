class Admin::PhotosController < Admin::BaseController
  before_action :set_photo, only: %i[edit update destroy]

  def index
    @photos = Photo.ordered
  end

  def new
    @photo = Photo.new
  end

  def create
    @photo = Photo.new(photo_params)
    if @photo.save
      redirect_to admin_photos_path, notice: "Photo ajoutée avec succès."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @photo.update(photo_params)
      redirect_to admin_photos_path, notice: "Photo mise à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @photo.destroy
    redirect_to admin_photos_path, notice: "Photo supprimée."
  end

  private

  def set_photo
    @photo = Photo.find(params[:id])
  end

  def photo_params
    params.require(:photo).permit(:title, :position, :image)
  end
end
