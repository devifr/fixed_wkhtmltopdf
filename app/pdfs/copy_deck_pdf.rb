class CopyDeckPdf
  include ActionView::Helpers::TextHelper

  attr_reader :pdf

  def initialize(copy_deck:)
    @copy_deck = copy_deck
    @products = copy_deck.product_names.join(", ")

    in_pacific_time do
      configure_pdf
      write_content
      write_footer
    end
  end

  def data
    pdf.render
  end

  def save(path)
    pdf.render_file(path)
  end

  private

  def in_pacific_time(&block)
    Time.use_zone("Pacific Time (US & Canada)", &block)
  end

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def configure_pdf
    # Configure the page
    @pdf = Prawn::Document.new(bottom_margin: 72)

    # Configure fonts
    pdf.font_families.update(
      "Myriad Set Pro" => {
        normal:      { file: Rails.root.join("app/pdfs/fonts/MyriadSetPro-Text.ttf"), font: "Myriad Set Pro Text" },
        bold:        { file: Rails.root.join("app/pdfs/fonts/MyriadSetPro-Bold.ttf"), font: "Myriad Set Pro Bold" },
        italic:      { file: Rails.root.join("app/pdfs/fonts/MyriadSetPro-Text-Italic.ttf"), font: "Myriad Set Pro Text Italic" },
        bold_italic: { file: Rails.root.join("app/pdfs/fonts/MyriadSetPro-Bold-Italic.ttf"), font: "Myriad Set Pro Bold Italic" }
      },
      "Font Awesome"   => {
        normal: { file: Rails.application.assets.find_asset("fontawesome-webfont.ttf").pathname }
      }
    )
    pdf.font("Myriad Set Pro")
    pdf.fallback_fonts = ["Font Awesome"]
  end

  def write_content
    # Title
    pdf.text " Copy Deck", size: 12
    pdf.move_down 27

    # Copy Deck table
    pdf.table(
      [
        [
          "Project Title",
          "Products",
          "Name",
          "Last Updated"
        ]
      ] +
      [
        [
          @copy_deck.project.name,
          @products,
          @copy_deck.name,
          "#{format_date(@copy_deck.updated_at)} by #{@copy_deck.last_updated_user&.name}"
        ]
      ],
      cell_style: {
        border_color: "DDDDDD",
        border_width: 0.5,
        borders:      [:bottom],
        padding:      [4, 6, 6, 6],
        size:         8
      },
      header:     true,
      row_colors: %w[F9F9F9 FFFFFF],
      width:      pdf.bounds.width
    ) do |table|
      table.row(0).font_style = :bold
      table.row(0).border_width = 1
      table.row(0).valign = :bottom
      table.column(1).width = 200
    end

    pdf.move_down 27

    PrawnHtml.append_html(pdf, @copy_deck.content_for_prawn)
  end

  def write_footer
    pdf.bounding_box [54, -9], width: 432, height: 27 do
      pdf.number_pages "Page <page> of <total>", align: :center, valign: :top, size: 8

      pdf.repeat :all do
        pdf.text_box "Confidential", align: :left, valign: :top, size: 8
        pdf.text_box format_date(Date.current), align: :right, valign: :top, size: 8
        pdf.text_box <<-TEXT.strip_heredoc, align: :center, valign: :bottom, size: 6
          NOTICE OF PROPRIETARY PROPERTY THE INFORMATION CONTAINED HEREIN IS THE PROPRIETARY PROPERTY OF APPLE INC. THE POSSESSOR AGREES TO THE FOLLOWING:
          (i) TO MAINTAIN THIS DOCUMENT IN CONFIDENCE, (ii) NOT TO REPRODUCE OR COPY IT (iii) NOT TO REVEAL OR PUBLISH IT IN WHOLE OR PART
        TEXT
      end
    end
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  def format_date(date)
    date&.strftime("%-m/%-d/%Y")
  end
end
