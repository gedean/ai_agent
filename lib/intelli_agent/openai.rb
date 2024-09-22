module IntelliAgent::OpenAI
  BASIC_MODEL = ENV.fetch('OPENAI_BASIC_MODEL', 'gpt-4o-mini')
  ADVANCED_MODEL = ENV.fetch('OPENAI_ADVANCED_MODEL', 'gpt-4o-2024-08-06')
  MAX_TOKENS = ENV.fetch('OPENAI_MAX_TOKENS', 16_383).to_i

  module ResponseExtender
    def content
      dig('choices', 0, 'message', 'content')
    end

    def message
      dig('choices', 0, 'message')
    end

    def content?
      !content.nil?
    end

    def tool_calls
      dig('choices', 0, 'message', 'tool_calls')
    end

    def tool_calls?
      !tool_calls.nil?
    end

    def functions
      return if tool_calls.nil?
      
      functions = tool_calls.filter { |tool| tool['type'].eql? 'function' }
      return if functions.empty?
      
      functions_list = []
      functions.map.with_index do |function, function_index|
        function_def = tool_calls.dig(function_index, 'function')
        functions_list << { id: function['id'], name: function_def['name'], arguments: Oj.load(function_def['arguments'], symbol_keys: true) }
      end

      functions_list
    end

    def functions?
      !functions.nil?
    end
  end

  def self.embed(input, model: 'text-embedding-3-large')
    response = OpenAI::Client.new.embeddings(parameters: { input:, model: })
    def response.embedding = dig('data', 0, 'embedding')
    response
  end

  def self.vision(prompt:, image_url:, model: :advanced, response_format: nil, max_tokens: MAX_TOKENS)
    model = select_model(model)
    messages = [{ type: :text, text: prompt },
                { type: :image_url, image_url: { url: image_url } }]

    parameters = { model: model, messages: [{ role: :user, content: messages }], max_tokens: }
    parameters[:response_format] = { type: 'json_object' } if response_format.eql?(:json)

    response = OpenAI::Client.new.chat(parameters:)
    
    def response.content = dig('choices', 0, 'message', 'content').strip

    response
  end  

  def self.single_prompt(prompt:, model: :basic, response_format: nil, max_tokens: MAX_TOKENS, tools: nil, function_run_context: self)
    chat(messages: [{ user: prompt }], model:, response_format:, max_tokens:, tools:, function_run_context:)
  end

  def self.single_chat(system:, user:, model: :basic, response_format: nil, max_tokens: MAX_TOKENS, tools: nil, function_run_context: self)
    chat(messages: [{ system: }, { user: }], model:, response_format:, max_tokens:, tools:, function_run_context:)
  end

  def self.chat(messages:, model: :basic, response_format: nil, max_tokens: MAX_TOKENS, tools: nil, function_run_context: self)
    model = select_model(model)
    messages = parse_messages(messages)
    
    parameters = { model:, messages:, max_tokens: }
    parameters[:response_format] = { type: 'json_object' } if response_format.eql?(:json)
    parameters[:tools] = tools if tools

    response = OpenAI::Client.new.chat(parameters:)
    response.extend(ResponseExtender)

    if response.functions?
      parameters[:messages] << response.message

      response.functions.each do |function|
        parameters[:messages] << {
          tool_call_id: function[:id],
          role: :tool,
          name: function[:name],
          content: parameters[:function_run_context].send(function[:name], **function[:arguments])
        }
      end

      response = OpenAI::Client.new.chat(parameters:)
      response.extend(ResponseExtender)
    end

    response
  end

  def self.models = OpenAI::Client.new.models.list

  def self.select_model(model)
    case model
    when :basic
      BASIC_MODEL
    when :advanced
      ADVANCED_MODEL
    else
      model
    end
  end

  def self.parse_messages(messages)
    case messages
    in [{ role: String, content: String }, *]
      messages
    else
      messages.map do |msg|
        role, content = msg.first
        { role: role.to_s, content: content }
      end
    end
  end
end