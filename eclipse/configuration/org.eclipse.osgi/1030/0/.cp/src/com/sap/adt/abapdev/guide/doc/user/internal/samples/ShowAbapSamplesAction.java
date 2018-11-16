package com.sap.adt.abapdev.guide.doc.user.internal.samples;

import java.util.Properties;

import org.eclipse.core.resources.IProject;
import org.eclipse.jface.text.ITextSelection;
import org.eclipse.jface.text.TextSelection;
import org.eclipse.swt.widgets.Display;
import org.eclipse.ui.IViewPart;
import org.eclipse.ui.PartInitException;
import org.eclipse.ui.intro.IIntroSite;
import org.eclipse.ui.intro.config.IIntroAction;
import org.eclipse.ui.part.IShowInTarget;
import org.eclipse.ui.part.ShowInContext;

import com.sap.adt.docu.ui.AbapLanguageHelpView;
import com.sap.adt.logging.AdtLogging;
import com.sap.adt.logging.IAdtLogger;
import com.sap.adt.tools.core.ui.dialogs.AbapProjectSelectionDialog;
import com.sap.adt.tools.core.ui.internal.infoview.ViewUtil;

public class ShowAbapSamplesAction implements IIntroAction {

	private static final String QUERY_ABAP_SAMPLES = "abenabap_examples"; //$NON-NLS-1$

	//private static final String ABENABAP_EXAMPLES = "examples"; //$NON-NLS-1$

	private static final IAdtLogger LOGGER = AdtLogging.getLogger(ShowAbapSamplesAction.class);

	@Override
	public void run(final IIntroSite site, final Properties params) {

		// Active help does not run on the UI thread, so we must use asyncExec
		Display.getDefault().asyncExec(new Runnable() {
			public void run() {
				// Open the ABAP project selection dialog
				IProject project = AbapProjectSelectionDialog.open(site.getShell(), null);

				// APAP project exists (push OK button)
				if (project != null) {
					IViewPart abapLanguageHelpView = null;
					try {
						// Shows the view the way that it gets the focus (basis for selectionChanged-event, see below)
						abapLanguageHelpView = new ViewUtil().showPinAbleView(AbapLanguageHelpView.ID);
					} catch (PartInitException e) {
						LOGGER.error(e, "Opening ABAP Language Help View failed."); //$NON-NLS-1$
					}

					if (abapLanguageHelpView instanceof IShowInTarget) {
						final IShowInTarget showInTargetView = ((IShowInTarget) abapLanguageHelpView);
						final ITextSelection textSelection = createTextSelection(QUERY_ABAP_SAMPLES);
						ShowInContext showInContext = new ShowInContext(project, textSelection);

						showInTargetView.show(showInContext);
					}
				}
			}
		});
	}

	private ITextSelection createTextSelection(final String selectedText) {

		final ITextSelection textSelection = new TextSelection(0, selectedText.length()) {
			@Override
			public String getText() {
				return selectedText;
			}
		};
		return textSelection;
	}

}