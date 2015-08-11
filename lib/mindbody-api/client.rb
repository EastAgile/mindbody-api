require 'mindbody-api/response'

module MindBody
  module Services
    class Client < Savon::Client

      def call(operation_name, locals = {}, &block)
        # Inject the auth params into the request and setup the
        # correct request structure
        @globals.log_level(MindBody.configuration.log_level)
        locals = locals.has_key?(:message) ? locals[:message] : locals
        locals = fixup_locals(locals)
        site_id = locals['SiteID']
        locals.delete('SiteID')
        params = {:message => {'Request' => auth_params(site_id).merge(locals)}}

        # Run the request
        response = super(operation_name, params, &block)
        Response.new(response)
      end

      private
      def auth_params(site_id)
        if site_id != nil
          site_ids = [site_id.to_s]
        else
          site_ids = MindBody.configuration.site_ids
        end
        params = {
          'SourceCredentials' => {
            'SourceName'=> MindBody.configuration.source_name,
            'Password'=> MindBody.configuration.source_key,
            'SiteIDs'=> {
              'int'=> site_ids
            }
          }
        }
        if MindBody.configuration.username.length > 0 && MindBody.configuration.password.length > 0
          params.merge!({
            'UserCredentials' => {
              'Username' => MindBody.configuration.username,
              'Password' => MindBody.configuration.password,
              'SiteIDs'=> {
                'int'=> site_ids
              }
            }
          })
        end
        params
      end

      def fixup_locals(locals)
        # TODO this needs fixed to support various list types
        locals.each_pair do |key, value|
          if value.is_a? Array
            locals[key] = {'int' => value}
          end
        end
      end
    end
  end
end
