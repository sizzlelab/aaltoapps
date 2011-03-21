class DownloadsController < ApplicationController
  load_and_authorize_resource :product
  load_and_authorize_resource :download, :through => :product

  def destroy
    @download.destroy

    respond_to do |format|
      format.html { redirect_to(@download.product, :notice => _('File deleted.')) }
      format.xml  { head :ok }
    end
  end

end
