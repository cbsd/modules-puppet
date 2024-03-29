require 'json'
require 'net/http'
require 'pp'
require 'uri'
Puppet::Type.type(:consul_acl).provide(
  :default
) do
  mk_resource_methods

  def self.prefetch(resources)
    resources.each do |name, resource|
      Puppet.debug("prefetching for #{name}")
      port = resource[:port]
      hostname = resource[:hostname]
      protocol = resource[:protocol]
      token = resource[:acl_api_token]
      tries = resource[:api_tries]

      found_acls = list_resources(token, port, hostname, protocol, tries).select do |acl|
        acl[:name] == name
      end

      found_acl = found_acls.first || nil
      if found_acl
        Puppet.debug("found #{found_acl.pretty_inspect}")
        resource.provider = new(found_acl)
      else
        Puppet.debug("found none #{name}")
        resource.provider = new({ ensure: :absent })
      end
    end
  end

  def self.list_resources(acl_api_token, port, hostname, protocol, tries)
    @acls ||= {}
    return @acls["#{acl_api_token}#{port}#{hostname}#{protocol}#{tries}"] if @acls["#{acl_api_token}#{port}#{hostname}#{protocol}#{tries}"]

    # this might be configurable by searching /etc/consul.d
    # but would break for anyone using nonstandard paths
    uri = URI("#{protocol}://#{hostname}:#{port}/v1/acl")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.instance_of? URI::HTTPS

    path = uri.request_uri + "/list?token=#{acl_api_token}"
    req = Net::HTTP::Get.new(path)
    res = nil
    res_code = nil

    # retry Consul API query for ACLs, in case Consul has just started
    (1..tries).each do |i|
      unless i == 1
        Puppet.debug("retrying Consul API query in #{i} seconds")
        sleep i
      end

      begin
        res = http.request(req)
        res_code = res.code
        break if res_code == '200'
      rescue Errno::ECONNREFUSED => e
        Puppet.debug("#{uri}/list?token=<redacted> #{e.class} #{e.message}")
        res_code = e.class.to_s
      end
    end

    if res_code == '200'
      acls = JSON.parse(res.body)
    else
      Puppet.warning("Cannot retrieve ACLs: invalid return code #{res_code} uri: #{path} body: #{req.body}")
      return {}
    end

    nacls = acls.collect do |acl|
      {
        name: acl['Name'],
        type: acl['Type'].to_sym,
        rules: acl['Rules'].empty? ? {} : JSON.parse(acl['Rules']),
        id: acl['ID'],
        acl_api_token: acl_api_token,
        port: port,
        hostname: hostname,
        protocol: protocol,
        api_tries: tries,
        ensure: :present
      }
    end

    @acls["#{acl_api_token}#{port}#{hostname}#{protocol}#{tries}"] = nacls
    nacls
  end

  def put_acl(method, body)
    uri = URI("#{@resource[:protocol]}://#{@resource[:hostname]}:#{@resource[:port]}/v1/acl")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.instance_of? URI::HTTPS
    acl_api_token = @resource[:acl_api_token]
    path = uri.request_uri + "/#{method}?token=#{acl_api_token}"
    req = Net::HTTP::Put.new(path)
    req.body = body.to_json if body
    res = http.request(req)
    raise(Puppet::Error, "Session #{name} create: invalid return code #{res.code} uri: #{path} body: #{req.body}") if res.code != '200'
  end

  def get_resource(name, port, hostname, protocol, tries)
    acl_api_token = @resource[:acl_api_token]
    resources = self.class.list_resources(acl_api_token, port, hostname, protocol, tries).select do |res|
      res[:name] == name
    end
    # if the user creates multiple with the same name this will do odd things
    resources.first || nil
  end

  def initialize(value = {})
    super(value)
    @property_flush = {}
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    @property_flush[:ensure] = :present
  end

  def destroy
    @property_flush[:ensure] = :absent
  end

  def flush
    name = @resource[:name]
    rules = if @resource[:rules]
              @resource[:rules].to_json
            else
              ''
            end
    type = @resource[:type]
    port = @resource[:port]
    hostname = @resource[:hostname]
    protocol = @resource[:protocol]
    tries = @resource[:api_tries]
    acl = get_resource(name, port, hostname, protocol, tries)
    if acl
      id = acl[:id]
      if @property_flush[:ensure] == :absent
        put_acl("destroy/#{id}", nil)
        return
      end
      put_acl('update', { 'id' => id.to_s,
                          'name' => name.to_s,
                          'type' => type.to_s,
                          'rules' => rules.to_s })

    else
      put_acl('create', { 'id' => (@resource[:id]).to_s,
                          'name' => name.to_s,
                          'type' => type.to_s,
                          'rules' => rules.to_s })
    end
    @property_hash.clear
  end
end
