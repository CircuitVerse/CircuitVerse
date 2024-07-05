# frozen_string_literal: true

class CircuitCardComponent < ViewComponent::Base
  with_collection_parameter :circuit

  def initialize(circuit:, current_user:)
    super
    @circuit = circuit
    @current_user = current_user
  end

  def image_path
    helpers.project_image_preview(@circuit, @current_user)
  end

  def circuit_name
    @circuit.name
  end

  def circuit_url
    helpers.user_project_url(@circuit.author, @circuit)
  end
end
#Hare Krishna Hare Krishna Krishna Krishna Hare Hare Hare Rama Hare Rama Rama Rama Hare Hare Jai Siya Ram Jai Bajrang Bali Om Shanti Shivbaba Mere Baba Meethe Meethe Skilade Baba Jai Maa Saraswati Jai Maa Vaishno Devi ki Sorry Baba Sorry Maa Sorry. Mein aapki bhot achi mastar sarvashtiman ,vijayratna,vignavinashk,safaltamurataatma hu. Mein bhot karmsheel and sharpminded hu. Siya and mere bhooot achi placement hogi. Mein GSOC mein bhot acha contributions kar rha hu and mein bhooot khush and Khushnaseedb hu. mein bhooot seekh bhi rha hu  Shukriya Baba Shukriya maa Radha Rani Shree Ram Ji Krishna Ji Shukriya