package net.youngdev.resume;

import static com.fasterxml.jackson.annotation.JsonAutoDetect.Visibility.ANY;
import static com.fasterxml.jackson.annotation.PropertyAccessor.FIELD;

import java.awt.Desktop;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.StringWriter;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Scanner;

import com.lowagie.text.DocumentException;
import freemarker.template.TemplateException;
import lombok.SneakyThrows;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.time.DateFormatUtils;

import org.apache.pdfbox.Loader;
import org.apache.pdfbox.io.RandomAccessReadBufferedFile;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.text.PDFTextStripper;

import org.apache.poi.xwpf.usermodel.XWPFDocument;
import org.apache.poi.xwpf.usermodel.XWPFParagraph;
import org.apache.poi.xwpf.usermodel.XWPFRun;
import org.docx4j.XmlUtils;
import org.docx4j.convert.in.xhtml.XHTMLImporterImpl;
import org.docx4j.openpackaging.packages.WordprocessingMLPackage;
import org.docx4j.openpackaging.parts.WordprocessingML.StyleDefinitionsPart;
import org.xhtmlrenderer.pdf.ITextRenderer;

import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.module.paramnames.ParameterNamesModule;

import freemarker.template.Configuration;
import freemarker.template.Template;
import freemarker.template.Version;
import lombok.extern.slf4j.Slf4j;

@Slf4j
public class App {
	private static final String EMAIL_CMD = "/Applications/Thunderbird.app/Contents/MacOS/thunderbird";
	private static final String OPTIONS = "to={0},subject=''Here is my résumé as requested'',body=''Please see attached'',attachment=''{1}''";

	public static void main(String[] args) throws Exception {
		App app = new App();
		List<String> argList = Arrays.asList(args);
		boolean anonymize = argList.contains("--headless");
		String recipient = argList.stream()
				.filter(it-> it.startsWith("--recipient="))
				.map(it->StringUtils.substringAfter(it, "=")).findFirst().orElse(null);

		String format = argList.stream()
				.filter(it-> it.startsWith("--format="))
				.map(it->StringUtils.substringAfter(it, "=")).findFirst().orElse("pdf");

		Map resume = app.getResumeModel(anonymize);
		
		app.runResume(resume, anonymize, recipient, format);

	}

	private Map getResumeModel(boolean headless) {
		String modelFile = "resume_model.json";
		
		
		HashMap model = new HashMap();
		try (InputStream is = Thread.currentThread().getContextClassLoader().getResourceAsStream(modelFile)) {

			ObjectMapper mapper = new ObjectMapper();
			mapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
			mapper.registerModule(new ParameterNamesModule());

			// make private fields of Person visible to Jackson
			mapper.setVisibility(FIELD, ANY);
			model = mapper.readValue(is, HashMap.class);
			
			if (headless) {
				model.put("email",null);
				model.put("name", "Candidate");
				model.put("phoneNumber", null);
			}
		} catch (Exception e) {
			log.warn("Error getting resume model", e);
		}
		return model;

	}
	public String processTemplate(Map resume) throws IOException, TemplateException {
		StringWriter out = new StringWriter();


		log.debug("heres the resume map: {}", resume);

		Map<String, Object> parameters = new HashMap<>();
		parameters.put("resume", resume);
		Configuration cfg = new Configuration(new Version(2, 3, 31));
		cfg.setClassForTemplateLoading(App.class, "/");
		Template temp = cfg.getTemplate("resume.ftl");
		temp.process(parameters, out);
		return out.toString();

	}

	@SneakyThrows
    public File outputDocx(String xhtml) throws FileNotFoundException {

		xhtml ="<html><body><h2>Summary</h2>Test 123</body></html>";
		File docx  = new File("resume.docx");

			WordprocessingMLPackage wordMLPackage = WordprocessingMLPackage.createPackage();

			XHTMLImporterImpl xHTMLImporter = new XHTMLImporterImpl(wordMLPackage);
			xHTMLImporter.setHyperlinkStyle("Hyperlink");
			//XHTMLImporter.setDivHandler(new DivToSdt());

			wordMLPackage.getMainDocumentPart().getContent().addAll(
					xHTMLImporter.convert( xhtml, null) );

			log.debug("{}",XmlUtils.marshaltoString(wordMLPackage
					.getMainDocumentPart().getJaxbElement(), true, true));


			wordMLPackage.save(docx);

			// Create a new WordprocessingMLPackage (DOCX)
//			WordprocessingMLPackage wordMLPackage = WordprocessingMLPackage.createPackage();
//			if (wordMLPackage.getMainDocumentPart().getStyleDefinitionsPart() == null) {
//				StyleDefinitionsPart stylesPart = new StyleDefinitionsPart();
//				stylesPart.setPackage(wordMLPackage);
//				stylesPart.unmarshalDefaultStyles();
//				wordMLPackage.getMainDocumentPart().addTargetPart(stylesPart);
//			}
//
//			// Convert XHTML to DOCX
//			XHTMLImporterImpl xhtmlImporter = new XHTMLImporterImpl(wordMLPackage);
//			wordMLPackage.getMainDocumentPart().getContent().addAll(xhtmlImporter.convert(xhtmlInputStream, null));
//
//			// Save DOCX file
//			wordMLPackage.save(docx);// Load the PDF document
			//PDDocument pdfDoc = PDDocument.load(pdfFile);
		log.debug("DOCX file generated successfully. {}", docx.getAbsolutePath());
		return docx;
	}


	public File outputPdf( String xhtml) throws IOException, DocumentException {
		File docx  = new File("resume.pdf");
		final ITextRenderer renderer = new ITextRenderer();
		renderer.setDocumentFromString(xhtml);
		renderer.layout();

		try (FileOutputStream fos = new FileOutputStream(docx)) {
			renderer.createPDF(fos);

		}

		log.debug("PDF file created at {}", docx.getAbsolutePath());
		return docx;
	}


	private void runResume(Map resume, boolean anonymize, String recipient, String format) throws Exception {
		File file = null;

		String html = processTemplate(resume);
		file = outputPdf(html);

		if ( format.equals("docx") ) {
			file = outputDocx(html);
		} else {
			if (!StringUtils.equals("pdf", format)) {
				log.warn("{} is not a supported format.  Using pdf instead", format);
			}

		}

		String input = "";
		Scanner scanner = new Scanner(new InputStreamReader(System.in));

		if (Desktop.isDesktopSupported()) {
			try {
				Desktop.getDesktop().open(file);
			} catch (IOException ex) {
				// no application registered for PDFs
			}
		}

		if (anonymize || StringUtils.isEmpty(recipient)) {
			try {
			Path s3NamedStream = new File("/Users/mattyoung/Documents/latest-resume-architect-2024.pdf").toPath();
			Path mylocalStream = new File("/Users/mattyoung/Documents/mattyoung-architect-resume-2024.pdf").toPath();
	
			Files.copy(file.toPath(), s3NamedStream, StandardCopyOption.REPLACE_EXISTING);
			Files.copy(file.toPath(), mylocalStream, StandardCopyOption.REPLACE_EXISTING);
			} catch (Exception e) {
				log.error("Exception", e);	
			}
			log.info("Copy complete");
		}

		if (StringUtils.isNotEmpty(recipient)) {
			String options = MessageFormat.format(OPTIONS, recipient, file.getAbsolutePath());
			log.debug("running command: {} --compose \"{}\"", EMAIL_CMD, options);
//			ProcessBuilder pb = new ProcessBuilder(cmd);
//			pb.inheritIO();
//			pb.directory(new File(System.getProperty("user.dir")));
//			pb.start();

			ArrayList<String> cmd = new ArrayList<String>();
			cmd.add(EMAIL_CMD);
			cmd.add("--compose");
			cmd.add(options);

			ProcessBuilder processBuilder = new ProcessBuilder(cmd);
			processBuilder.inheritIO().directory(new File(System.getProperty("user.dir"))).start().waitFor();

		}
	}

}
