# In the future, this became a bus to more than one AI provider
module IntelliAgent::OpenAI
  BASIC_MODEL = ENV.fetch('OPENAI_BASIC_MODEL', 'gpt-4o-mini')
  ADVANCED_MODEL = ENV.fetch('OPENAI_ADVANCED_MODEL', 'gpt-4o-2024-08-06')

  def self.embed(input, model: 'text-embedding-3-large')
    response = OpenAI::Client.new.embeddings(parameters: { input:, model: })
    response.dig('data', 0, 'embedding')
  end

  def self.single_prompt(prompt:, model: :basic, response_format: nil)
    model = select_model(model)
    
    parameters = { model:, messages: [{ role: 'user', content: prompt }] }

    parameters[:response_format] = { type: 'json_object' } if response_format.eql?(:json)

    response = OpenAI::Client.new.chat(parameters:)

    if response_format.nil?
      response.dig('choices', 0, 'message', 'content').strip
    else
      response
    end
  end

  def self.vision(prompt:, image_url:, model: :advanced, response_format: nil)
    model = select_model(model)
    messages = [{ type: :text, text: prompt },
                { type: :image_url, image_url: { url: image_url } }]

    parameters = { model: model, messages: [{ role: :user, content: messages }] }
    parameters[:response_format] = { type: 'json_object' } if response_format.eql?(:json)

    response = OpenAI::Client.new.chat(parameters:)

    if response_format.nil?
      response.dig('choices', 0, 'message', 'content').strip
    else
      response
    end
  end

  def self.single_chat(system:, user:, model: :basic, response_format: nil)
    model = select_model(model)
    parameters = { model:,
                   messages: [
                     { role: 'system', content: system },
                     { role: 'user', content: user }
                   ] }

    parameters[:response_format] = { type: 'json_object' } if response_format.eql?(:json)

    response = OpenAI::Client.new.chat(parameters:)
    if response_format.nil?
      response.dig('choices', 0, 'message', 'content').strip
    else
      response
    end
  end

  def self.chat(messages:, model: :basic, response_format: nil)
    model = select_model(model)
    parameters = { model:, messages: }
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
end