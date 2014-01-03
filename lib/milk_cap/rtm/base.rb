#--
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Made in Japan.
#++

require 'cgi'
require 'net/http'
require 'json' # gem install 'json' or 'json_pure'

begin

  require 'md5'

  def md5 (s)
    MD5.md5(s).to_s
  end

rescue LoadError # ruby 1.9.x

  require 'digest/md5'

  def md5 (s)
    Digest::MD5.hexdigest(s)
  end
end


module MilkCap
module RTM

  VERSION = '0.5.1'

  AUTH_ENDPOINT = "http://www.rememberthemilk.com/services/auth/"
  REST_ENDPOINT = "http://api.rememberthemilk.com/services/rest/"

  # Signs the RTM request (sets the 'api_sig' parameter).
  #
  def self.sign (params, secret) #:nodoc:

    params['api_sig'] = md5(secret + params.sort.flatten.join)

    params
  end

  # Calls an API method (milk the cow).
  #
  def self.milk (params={}) #:nodoc:

    sleep 1

    endpoint = params.delete(:endpoint)
    endpoint = AUTH_ENDPOINT if endpoint == :auth
    endpoint = endpoint || REST_ENDPOINT

    ps = params.inject({}) { |r, (k, v)| r[k.to_s] = v; r }

    ps['api_key'] = params[:api_key] || ENV['RTM_API_KEY']

    raise 'API_KEY missing from environment or parameters, cannot proceed' \
      unless ps['api_key']

    ps['frob'] = params[:frob] || ENV['RTM_FROB']
    ps.delete('frob') if ps['frob'] == nil

    ps['auth_token'] = params[:auth_token] || ENV['RTM_AUTH_TOKEN']
    ps.delete('auth_token') if ps['auth_token'] == nil

    ps['format'] = 'json'

    secret = params[:shared_secret] || ENV['RTM_SHARED_SECRET']

    sign(ps, secret)

    res = get(endpoint, ps)

    JSON.parse(res)['rsp']
  end

  # Requests a timeline from RTM.
  #
  def self.get_timeline #:nodoc:

    milk(:method => 'rtm.timelines.create')['timeline']
  end

  def self.get(endpoint, hash)
    query = hash.collect { |item| "#{item[0].to_s}=#{CGI.escape(item[1].to_s)}" }.join("&")
    url = endpoint + '?' + query
    Net::HTTP.get(URI.parse(url))
  end

end
end
