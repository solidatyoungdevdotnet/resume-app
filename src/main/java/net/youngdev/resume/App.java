package net.youngdev.resume;

import static com.fasterxml.jackson.annotation.JsonAutoDetect.Visibility.ANY;
import static com.fasterxml.jackson.annotation.PropertyAccessor.FIELD;

import java.awt.Desktop;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.StringWriter;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.HashMap;
import java.util.Map;
import java.util.Scanner;

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
	private static final String OPTIONS = "to={0},subject=''{1} Invoice'',body=''Please see attached'',attachment=''{2}''";

	public static void main(String[] args) throws Exception {
		App app = new App();
		Map resume = app.getResumeModel();
		app.runResume(resume);

	}

	private Map getResumeModel() {
		HashMap model = new HashMap();
		try (InputStream is = Thread.currentThread().getContextClassLoader().getResourceAsStream("resume_model.json")) {

			ObjectMapper mapper = new ObjectMapper();
			mapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
			mapper.registerModule(new ParameterNamesModule());

			// make private fields of Person visible to Jackson
			mapper.setVisibility(FIELD, ANY);
			model = mapper.readValue(is, HashMap.class);
		} catch (Exception e) {
			log.warn("Error getting resume model", e);
		}
		return model;

	}

	private void runResume(Map resume) throws Exception {
		File pdf = null;
		StringWriter out = new StringWriter();

		log.debug("heres the resume map: {}", resume);

		Map<String, Object> parameters = new HashMap<>();
		parameters.put("resume", resume);
		Configuration cfg = new Configuration(new Version(2, 3, 31));
		cfg.setClassForTemplateLoading(App.class, "/");
		// cfg.setObjectWrapper( new DefaultObjectWrapper() );
		Template temp = cfg.getTemplate("resume.ftl");
		temp.process(parameters, out);
		pdf = new File("resume.pdf");
//		FileUtils.writeStringToFile(intermediate, out.toString());
//		
		log.debug("html :\n{}", out.toString());
		final ITextRenderer renderer = new ITextRenderer();
		renderer.setDocumentFromString(out.toString());
		renderer.layout();

		try (FileOutputStream fos = new FileOutputStream(pdf)) {
			renderer.createPDF(fos);

		}
		String input = "";
		Scanner scanner = new Scanner(new InputStreamReader(System.in));

		if (Desktop.isDesktopSupported()) {
			try {
				Desktop.getDesktop().open(pdf);
			} catch (IOException ex) {
				// no application registered for PDFs
			}
		}

		try {
		Path s3NamedStream = new File("/Users/mattyoung/Documents/latest-resume-architect-2024.pdf").toPath();
		Path mylocalStream = new File("/Users/mattyoung/Documents/mattyoung-architect-resume-2024.pdf").toPath();

		Files.copy(pdf.toPath(), s3NamedStream, StandardCopyOption.REPLACE_EXISTING);
		Files.copy(pdf.toPath(), mylocalStream, StandardCopyOption.REPLACE_EXISTING);
		} catch (Exception e) {
			log.error("Exception", e);	
		}
		log.info("Copy complete");

	}

}
