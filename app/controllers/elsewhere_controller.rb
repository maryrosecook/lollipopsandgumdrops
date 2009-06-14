class ElsewhereController < ApplicationController

  def last_fm
    redirect_url = "/recommendations"
    if Util.ne(params[:id])
      if last_fm_url = Lastfming::get_artist_url(params[:id])
        redirect_url = last_fm_url
      end
    end
  
    redirect_to(redirect_url)
  end

  def myspace
    redirect_url = "/recommendations"
    if Util.ne(params[:id])
      if myspace_url = Yahooing::get_artist_myspace_url(params[:id])
        redirect_url = myspace_url
      end
    end
  
    redirect_to(redirect_url)
  end
end