require 'sinatra'
require 'sinatra/activerecord'
Dir["./models/*.rb"].each {|file| require file }

WEB_NAME = "MY WEB NAME"
ROOT = "http://localhost:9393/admin"

helpers do
  def protected!
    unless authorized?
      response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
      throw(:halt, [401, "Not authorized\n"])
    end
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == ['username', 'password']
  end
  
  def logout!
    @auth = nil
  end
  
  def title(param=nil)
    if param
      "#{WEB_NAME} | #{param}"
    else
      "#{WEB_NAME}"
    end
  end
  
  def link_to name, url_fragment, options = {}
    link = "<a href='#{url_fragment}' "
    link += "target='_blank' " if options[:mode] == :new_window
    link += "class='#{options[:class]}'" if options[:class]
    link += ">#{name}</a>"
  end
end

get '/' do
  redirect ROOT
end

get '/admin' do
  protected!
  @redirects = Redirects.all
  erb :admin
end

get '/logout' do
  logout!
  redirect '/'
end

post '/admin/create_redirect' do
  protected!
  new_redirect = Redirects.new({:name => params[:name], :subdomain => params[:subdomain], :url => params[:url]})
  if new_redirect.save
    @message = "The record was saved"
  else
    @message = "The subdomain is already taken"
  end
  @redirects = Redirects.all
  erb :admin
end

get '/admin/:id/edit' do
  protected!
  @redirect = Redirects.find params[:id]
  erb :edit
end

post '/admin/:id/update' do
  protected!
  redirect = Redirects.find params[:id]
  if redirect.update_attributes({:name =>params[:name], :subdomain => params[:subdomain], :url => params[:url]})
    @message = "The record was updated"
  else
    @message = "There was a problem saving the record"
  end
  @redirects = Redirects.all
  erb :admin
end

get '/admin/:id/destroy' do
  protected!
  redirect = Redirects.find params[:id]
  redirect.destroy
  @message = "The record was destroyed"
  @redirects = Redirects.all
  erb :admin
end

get '/:page_name' do
  @redirect = Redirects.where("subdomain = '#{params[:page_name].downcase}'").first
  if @redirect
    erb :frame
  else
    redirect '/'
  end
end
