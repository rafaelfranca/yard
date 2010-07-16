module YARD::Templates::Helpers
  module BaseHelper
    attr_accessor :object, :serializer
    
    # An object that keeps track of global state throughout the entire template 
    # rendering process (including any sub-templates).
    # 
    # @return [OpenStruct] a struct object that stores state
    # @since 0.6.0
    def globals; options[:__globals] end
    
    # Runs a list of objects against the {Verifier} object passed into the 
    # template and returns the subset of verified objects.
    # 
    # @param [Array<CodeObjects::Base>] list a list of code objects
    # @return [Array<CodeObjects::Base>] a list of code objects that match
    #   the verifier. If no verifier is supplied, all objects are returned.
    def run_verifier(list)
      options[:verifier] ? options[:verifier].run(list) : list
    end
    
    # This is used a lot by the HtmlHelper and there should
    # be some helper to "clean up" text for whatever, this is it.
    def h(text)
      text
    end
    
    def linkify(*args) 
      if args.first.is_a?(String)
        case args.first
        when %r{://}, /^mailto:/
          link_url(args[0], args[1], {:target => '_parent'}.merge(args[2]||{}))
        when /^include:(\S+)/
          path = $1
          if obj = YARD::Registry.resolve(object.namespace, path)
            link_include_object(obj)
          else
            log.warn "Cannot find object at `#{path}' for inclusion"
          end
        when /^file:(\S+?)(?:#(\S+))?$/
          link_file($1, args[1] ? args[1] : $1, $2)
        else
          link_object(*args)
        end
      else
        link_object(*args)
      end
    end
    
    # Includes an object's docstring into output.
    # @since 0.6.0
    def link_include_object(object)
      object.docstring
    end

    # Links to an object with an optional title
    # 
    # @param [CodeObjects::Base] object the object to link to
    # @param [String] title the title to use for the link
    # @return [String] the linked object
    def link_object(object, title = nil)
      return title if title
      
      case object
      when YARD::CodeObjects::Base, YARD::CodeObjects::Proxy
        object.path
      when String, Symbol
        P(object).path
      else
        object
      end
    end
    
    # Links to a URL
    # 
    # @param [String] url the URL to link to
    # @param [String] title the optional title to display the link as
    # @param [Hash] params optional parameters for the link
    # @return [String] the linked URL
    def link_url(url, title = nil, params = nil)
      url
    end
    
    # @since 0.5.5
    def link_file(filename, title = nil, anchor = nil)
      filename
    end
    
    def format_types(list, brackets = true)
      list.nil? || list.empty? ? "" : (brackets ? "(#{list.join(", ")})" : list.join(", "))
    end

    # @example Formatted type of an exception class
    #   o = ClassObject.new(:root, :MyError)
    #   o.superclass = P('RuntimeError')
    #   format_object_type(o) # => "Exception"
    # @example Formatted type of a method
    #   o = MethodObject.new(:root, :to_s)
    #   format_object_type(o) # => "Method"
    # @param [CodeObjects::Base] object the object to retrieve the type for
    # @return [String] the human-readable formatted {CodeObjects::Base#type #type} 
    #   for the object
    def format_object_type(object)
      case object
      when YARD::CodeObjects::ClassObject
        object.is_exception? ? "Exception" : "Class"
      else
        object.type.to_s.capitalize
      end
    end
    
    # @example
    #   s = format_object_title ModuleObject.new(:root, :MyModuleName)
    #   s # => "Module: MyModuleName"
    # @param [CodeObjects::Base] object the object to retrieve a title for
    # @return [String] the page title name for a given object
    def format_object_title(object)
      case object
      when YARD::CodeObjects::RootObject
        "Top Level Namespace"
      else
        format_object_type(object) + ": " + object.path
      end
    end
    
    # Indents and formats source code
    # 
    # @param [String] value the input source code
    # @return [String] formatted source code
    def format_source(value)
      sp = value.split("\n").last[/^(\s+)/, 1]
      num = sp ? sp.size : 0
      value.gsub(/^\s{#{num}}/, '')
    end
  end
end
