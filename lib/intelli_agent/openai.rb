module IntelliAgent::OpenAI
  BASIC_MODEL = ENV.fetch('OPENAI_BASIC_MODEL', 'gpt-4o-mini')
  ADVANCED_MODEL = ENV.fetch('OPENAI_ADVANCED_MODEL', 'gpt-4o-2024-08-06')
  MAX_TOKENS = ENV.fetch('OPENAI_MAX_TOKENS', 16383)

  def self.embed(input, model: 'text-embedding-3-large')
    response = OpenAI::Client.new.embeddings(parameters: { input:, model: })
    response.dig('data', 0, 'embedding')
  end

  def self.single_prompt(prompt:, model: :basic, response_format: nil, max_tokens: MAX_TOKENS)
    model = select_model(model)
    
    parameters = { model:, messages: [{ role: 'user', content: prompt }], max_tokens: }
    parameters[:response_format] = { type: 'json_object' } if response_format.eql?(:json)
    
    response = OpenAI::Client.new.chat(parameters:)

    if response_format.nil?
      response.dig('choices', 0, 'message', 'content').strip
    else
      response
    end
  end

  def self.vision(prompt:, image_url:, model: :advanced, response_format: nil, max_tokens: MAX_TOKENS)
    model = select_model(model)
    messages = [{ type: :text, text: prompt },
                { type: :image_url, image_url: { url: image_url } }]

    parameters = { model: model, messages: [{ role: :user, content: messages }], max_tokens: }
    parameters[:response_format] = { type: 'json_object' } if response_format.eql?(:json)

    response = OpenAI::Client.new.chat(parameters:)

    if response_format.nil?
      response.dig('choices', 0, 'message', 'content').strip
    else
      response
    end
  end

  def self.single_chat(system:, user:, model: :basic, response_format: nil, max_tokens: MAX_TOKENS)
    model = select_model(model)
    parameters = { model:,
                   messages: [
                     { role: 'system', content: system },
                     { role: 'user', content: user }
                   ], max_tokens: }

    parameters[:response_format] = { type: 'json_object' } if response_format.eql?(:json)

    response = OpenAI::Client.new.chat(parameters:)
    if response_format.nil?
      response.dig('choices', 0, 'message', 'content').strip
    else
      response
    end
  end

  def self.chat(messages:, model: :basic, response_format: nil, max_tokens: MAX_TOKENS)
    model = select_model(model)
    
    messages = determine_message_format(messages).eql?(:short_format) ? convert_message_to_standard_format(messages) : messages
    
    parameters = { model:, messages:, max_tokens: }
    parameters[:response_format] = { type: 'json_object' } if response_format.eql?(:json)

    response = OpenAI::Client.new.chat(parameters:)
    if response_format.nil?
      response.dig('choices', 0, 'message', 'content').strip
    else
      response
    end
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

  def self.determine_message_format(messages)
    case messages
    in [{ role: String, content: String }, *]
      :standard_format
    in [{ system: String }, { user: String }, *]
      :short_format
    else
      :unknown_format
    end
  end

  def self.convert_message_to_standard_format(messages)
    messages.map do |msg|
      role, content = msg.first
      { role: role.to_s, content: content }
    end
  end  
end