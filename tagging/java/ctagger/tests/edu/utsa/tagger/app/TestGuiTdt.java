package edu.utsa.tagger.app;

import static org.junit.Assert.assertTrue;

import java.io.IOException;

import org.junit.Test;

import edu.utsa.tagger.Loader;
import edu.utsa.tagger.gui.GuiModelFactory;

public class TestGuiTdt {

	@Test
	public void test() throws IOException {
		String hedXML = TestUtilities.getResourceAsString(TestUtilities.HedFileName);
		String tdtData = TestUtilities.getResourceAsString(TestUtilities.DelimitedString);
		String[] result = Loader.load(hedXML, tdtData, Loader.TAG_EDIT_ALL, 0, "Tagger Test - Tab-delimited Text data",
				2, new GuiModelFactory(), true, true);
		System.out.println(result[1]);
		assertTrue(result != null);

	}

}
