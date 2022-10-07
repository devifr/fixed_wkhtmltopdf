class HomeController < ApplicationController
  def index
    @icons = []
  end
  
  def wicked_pdf
    respond_to do |format|
      format.js
      format.pdf do
        generate_pdf
      end
    end
  end

  def pdfkit
    kit = PDFKit.new(as_html, page_size: 'A4')
    kit.to_pdf
  end

  def prawn
  end

  def generate_pdf
    render  pdf:    "Pdf3 ", encoding: "utf8", disposition: :attachment, # attachment
            margin: { top: 10, left: 12, bottom: 17 }, template: "home/content.html.erb",
            footer: {content: render_to_string('home/footer.html.erb', layout: nil)}
  end

  def as_html
    render template: "home/content.html.erb", layout: "pdf"
  end

end