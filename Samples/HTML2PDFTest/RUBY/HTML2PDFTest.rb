#---------------------------------------------------------------------------------------
# Copyright (c) 2001-2022 by PDFTron Systems Inc. All Rights Reserved.
# Consult LICENSE.txt regarding license information.
#---------------------------------------------------------------------------------------

require '../../../PDFNetC/Lib/PDFNetRuby'
include PDFNetRuby
require '../../LicenseKey/RUBY/LicenseKey'

$stdout.sync = true

#---------------------------------------------------------------------------------------
# The following sample illustrates how to convert HTML pages to PDF format using
# the HTML2PDF class.
# 
# 'pdftron.PDF.HTML2PDF' is an optional PDFNet Add-On utility class that can be 
# used to convert HTML web pages into PDF documents by using an external module (html2pdf).
#
# html2pdf modules can be downloaded from http:#www.pdftron.com/pdfnet/downloads.html.
#
# Users can convert HTML pages to PDF using the following operations:
# - Simple one line static method to convert a single web page to PDF. 
# - Convert HTML pages from URL or string, plus optional table of contents, in user defined order. 
# - Optionally configure settings for proxy, images, java script, and more for each HTML page. 
# - Optionally configure the PDF output, including page size, margins, orientation, and more. 
# - Optionally add table of contents, including setting the depth and appearance.
#---------------------------------------------------------------------------------------

	output_path = "../../TestFiles/Output/html2pdf_example"
	host = "https://www.pdftron.com"
	page0 = "/"
	page1 = "/support"
	page2 = "/blog"
	
	# The first step in every application using PDFNet is to initialize the 
	# library and set the path to common PDF resources. The library is usually 
	# initialized only once, but calling Initialize() multiple times is also fine.
	PDFNet.Initialize(PDFTronLicense.Key)
	
	# For HTML2PDF we need to locate the html2pdf module. If placed with the 
	# PDFNet library, or in the current working directory, it will be loaded
	# automatically. Otherwise, it must be set manually using HTML2PDF.SetModulePath.
	HTML2PDF.SetModulePath("../../../PDFNetC/Lib/");
	if !HTML2PDF.IsModuleAvailable
		puts 'Unable to run HTML2PDFTest: PDFTron SDK HTML2PDF module not available.'
		puts '---------------------------------------------------------------'
		puts 'The HTML2PDF module is an optional add-on, available for download'
		puts 'at http://www.pdftron.com/. If you have already downloaded this'
		puts 'module, ensure that the SDK is able to find the required files'
		puts 'using the HTML2PDF.SetModulePath function.'
		return 
	end

	#--------------------------------------------------------------------------------
	# Example 1) Simple conversion of a web page to a PDF doc. 
	
	doc = PDFDoc.new()
	# now convert a web page, sending generated PDF pages to doc
	converter = HTML2PDF.new()
	converter.InsertFromURL(host + page0)
	if converter.Convert(doc)
		doc.Save(output_path + "_01.pdf", SDFDoc::E_linearized)
	else
		print "Conversion failed."
	end
	
	#--------------------------------------------------------------------------------
	# Example 2) Modify the settings of the generated PDF pages and attach to an
	# existing PDF document. 
	
	# open the existing PDF, and initialize the security handler
	doc = PDFDoc.new("../../TestFiles/numbered.pdf")
	doc.InitSecurityHandler()
	
	# create the HTML2PDF converter object and modify the output of the PDF pages
	converter = HTML2PDF.new()
	converter.SetPaperSize(PrinterMode::E_11x17)
	
	# insert the web page to convert
	converter.InsertFromURL(host + page0)
	
	# convert the web page, appending generated PDF pages to doc
	if converter.Convert(doc)
		doc.Save(output_path + "_02.pdf", SDFDoc::E_linearized)
	else
		print "Conversion failed. HTTP Code: " + converter.GetHTTPErrorCode().to_s + "\n" + converter.GetLog()
	end
	
	#--------------------------------------------------------------------------------
	# Example 3) Convert multiple web pages
	
	doc = PDFDoc.new()
	converter = HTML2PDF.new()

	header = "<div style='width:15%;margin-left:0.5cm;text-align:left;font-size:10px;color:#0000FF'><span class='date'></span></div><div style='width:70%;direction:rtl;white-space:nowrap;overflow:hidden;text-overflow:clip;text-align:center;font-size:10px;color:#0000FF'><span>PDFTRON HEADER EXAMPLE</span></div><div style='width:15%;margin-right:0.5cm;text-align:right;font-size:10px;color:#0000FF'><span class='pageNumber'></span> of <span class='totalPages'></span></div>"
	footer = "<div style='width:15%;margin-left:0.5cm;text-align:left;font-size:7px;color:#FF00FF'><span class='date'></span></div><div style='width:70%;direction:rtl;white-space:nowrap;overflow:hidden;text-overflow:clip;text-align:center;font-size:7px;color:#FF00FF'><span>PDFTRON FOOTER EXAMPLE</span></div><div style='width:15%;margin-right:0.5cm;text-align:right;font-size:7px;color:#FF00FF'><span class='pageNumber'></span> of <span class='totalPages'></span></div>"
	converter.SetHeader(header)
	converter.SetFooter(footer)
	converter.SetMargins("1cm", "2cm", ".5cm", "1.5cm")
    
	settings = WebPageSettings.new()
	settings.SetZoom(0.5)
	converter.InsertFromURL(host + page0, settings)
	is_conversion_0_successful = converter.Convert(doc)

	# convert page 1 with the same settings, appending generated PDF pages to doc
	converter.InsertFromURL(host + page1, settings)
	is_conversion_1_successful = converter.Convert(doc)
	
	# convert page 2 with different settings, appending generated PDF pages to doc
	another_converter = HTML2PDF.new()
	another_converter.SetLandscape(true)
	another_settings = WebPageSettings.new()
	another_settings.SetPrintBackground(false)
	another_converter.InsertFromURL(host + page2, another_settings)
	is_conversion_2_successful = another_converter.Convert(doc)
    
	if is_conversion_0_successful and is_conversion_1_successful and is_conversion_2_successful
		doc.Save(output_path + "_03.pdf", SDFDoc::E_linearized)
	else
		print "Conversion failed. HTTP Code: " + converter.GetHTTPErrorCode().to_s + "\n" + converter.GetLog()
	end
		
	#--------------------------------------------------------------------------------
	# Example 4) Convert HTML string to PDF. 
	
	doc = PDFDoc.new()
	converter = HTML2PDF.new()
	
	# Our HTML data
	html = "<html><body><h1>Heading</h1><p>Paragraph.</p></body></html>"
	
	# Add html data
	converter.InsertFromHtmlString(html)
	# Note, InsertFromHtmlString can be mixed with the other Insert methods.
	
	if converter.Convert(doc)
		doc.Save(output_path + "_04.pdf", SDFDoc::E_linearized)
	else
		print "Conversion failed. HTTP Code: " + converter.GetHTTPErrorCode().to_s + "\n" + converter.GetLog()
	end
	PDFNet.Terminate

