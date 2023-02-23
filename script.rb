require 'yaml'
require 'ovh' # gem install ovh
require 'date'
require 'net/http'
require 'uri'
require 'json'
require 'logger'

CONFIG = YAML.load_file('config.yml')
LOGGER = Logger.new(CONFIG["system"]["log_folder"]+'ovh.log', 'monthly')
LOGGER.level = CONFIG["system"]["log_level"]

Ovh.configure do |config|
    config.application_key        =   CONFIG["ovh"]["application_key"]
    config.application_secret     =   CONFIG["ovh"]["application_secret"]
    config.consumer_key           =   CONFIG["ovh"]["consumer_key"]
end


client = Ovh::Client.new

now = DateTime.now
morning = DateTime.parse(now.strftime("%Y-%m-%dT00:00:00%z"))
yesterday = morning - 1

bills = client.get("/me/bill?date.from="+URI.encode_www_form_component(yesterday.to_s)+"&date.to="+URI.encode_www_form_component(morning.to_s))

subject = CONFIG["sendinblue"]["subject"] + " - " + now.strftime("%d/%m/%Y %Hh%M")

html_title = "<h2>=== " + subject + " ===</h2>"

html_text = bills.map do |bill_id|

    bill = client.get("/me/bill/"+bill_id)

    html_text = "<h4>Facture n° #{ bill["billId"] } du #{ DateTime.parse(bill["date"]).strftime("%d/%m/%Y %Hh%M") } - Montant  #{ bill["priceWithoutTax"]["text"] } HT / #{ bill["priceWithTax"]["text"] } TTC</h4>"
    html_text += "<a href='#{bill["pdfUrl"]}'>Télécharger la facture</a>"
    html_text += "<br/><br/>"
    html_text

end.join("<br/><br/>")

unless html_text.empty?
    html_text = html_title + html_text
    LOGGER.debug(html_text)

    uri = URI.parse("https://api.sendinblue.com/v3/smtp/email")
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json"
    request["Accept"] = "application/json"
    request["Api-Key"] = CONFIG["sendinblue"]["api_key"]
    request.body = JSON.dump({
    "subject" => CONFIG["sendinblue"]["subject"] + " - " + now.strftime("%d/%m/%Y %Hh%M"),
    "htmlContent" => html_text,
    "sender" => CONFIG["sendinblue"]["sender"],
    "to" => CONFIG["sendinblue"]["to"]
    })

    req_options = {
    use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
    end

    LOGGER.info(response.code.to_s + " - " + bills.length.to_s + " facture(s)")
    LOGGER.debug(response.body)

else
    LOGGER.info("Aucune facture à envoyer")
end