require 'pdfkit'
use PDFKit::Middleware, {print_media_type: true}
require "#{File.dirname(__FILE__)}/sahib"
run Sinatra::Application
