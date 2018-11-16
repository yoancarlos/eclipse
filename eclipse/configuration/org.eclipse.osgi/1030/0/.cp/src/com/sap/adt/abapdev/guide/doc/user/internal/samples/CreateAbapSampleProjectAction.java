package com.sap.adt.abapdev.guide.doc.user.internal.samples;

import java.util.HashSet;
import java.util.Properties;
import java.util.Set;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IConfigurationElement;
import org.eclipse.core.runtime.IExtension;
import org.eclipse.core.runtime.Platform;
import org.eclipse.jface.dialogs.Dialog;
import org.eclipse.jface.viewers.StructuredSelection;
import org.eclipse.jface.window.Window;
import org.eclipse.jface.wizard.IWizard;
import org.eclipse.jface.wizard.WizardDialog;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Tree;
import org.eclipse.swt.widgets.TreeItem;
import org.eclipse.ui.IPageLayout;
import org.eclipse.ui.PartInitException;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.intro.IIntroSite;
import org.eclipse.ui.intro.config.IIntroAction;
import org.eclipse.ui.navigator.CommonViewer;

import com.sap.adt.logging.AdtLogging;
import com.sap.adt.logging.IAdtLogger;
import com.sap.adt.project.ui.util.ProjectExplorerUtil;
import com.sap.adt.projectexplorer.ui.internal.node.AbapFavoritePackagesNode;
import com.sap.adt.tools.core.ui.AbapCoreUi;
import com.sap.adt.tools.core.ui.internal.project.wizard.NewAbapProjectWizard;

public class CreateAbapSampleProjectAction implements IIntroAction {

	public static final String VIEW_ID_PE = IPageLayout.ID_PROJECT_EXPLORER;

	private static final IAdtLogger LOGGER = AdtLogging.getLogger(ShowAbapSamplesAction.class);

	private final class ShowNewAbapProjectWizardRunnable implements Runnable {
		private static final String ATTRIBUTE_NAME_ID = "id"; //$NON-NLS-1$
		private static final String ELEMENT_NAME_WIZARD = "wizard"; //$NON-NLS-1$
		private final Set<String> favoritePackages;

		public ShowNewAbapProjectWizardRunnable(Set<String> favoritePackages) {
			this.favoritePackages = favoritePackages;

		}

		public void run() {
			// Open the ABAP project selection dialog
			IProject project = showNewWizard(PlatformUI.getWorkbench().getActiveWorkbenchWindow().getShell());
			try {
				PlatformUI.getWorkbench().getActiveWorkbenchWindow().getActivePage().showView(VIEW_ID_PE);
				CommonViewer projectExplorer = ProjectExplorerUtil.createInstance().getProjectExplorer();
				Tree tree = projectExplorer.getTree();
				TreeItem[] items = tree.getItems();
				projectExplorer.expandToLevel(project, 1);
				expandFavoritePackagesNodeOfProject(project, projectExplorer, items);
			} catch (PartInitException e) {
				LOGGER.error(e);
			}
		}

		protected void expandFavoritePackagesNodeOfProject(IProject searchedProject, CommonViewer projectExplorer, TreeItem[] items) {
			String projectName = searchedProject.getName();
			for (TreeItem treeItem : items) {
				IProject project = (IProject) treeItem.getData();
				if (projectName.equals(project.getName())) {
					expandFavoritePackagesNode(projectExplorer, treeItem);
				}
			}
		}

		protected void expandFavoritePackagesNode(CommonViewer projectExplorer, TreeItem projectItem) {
			TreeItem[] children = projectItem.getItems();
			for (TreeItem treeItem : children) {
				Object data = treeItem.getData();
				if (data instanceof AbapFavoritePackagesNode) {
					projectExplorer.expandToLevel(data, 1);
				}
			}
		}

		private IProject showNewWizard(Shell shell) {
			IConfigurationElement configElement = getConfigElement();
			NewAbapProjectWizard wizard = new NewAbapProjectWizard(this.favoritePackages);
			try {
				wizard.setInitializationData(configElement, null, null);
				wizard.init(PlatformUI.getWorkbench(), StructuredSelection.EMPTY);
				WizardDialog wizardDialog = new WizardDialog(shell, wizard);
				return doShowNewWizard(wizard, wizardDialog);
			} catch (CoreException e) {
				return null;
			}

		}

		private IConfigurationElement getConfigElement() {
			IExtension[] excludedTypeExtensions = Platform.getExtensionRegistry().getExtensionPoint(NewAbapProjectWizard.EXTENSION_ID)
					.getExtensions();

			// add all types with special settings for the project explorer
			for (IExtension extension : excludedTypeExtensions) {
				IConfigurationElement[] elements = extension.getConfigurationElements();
				for (IConfigurationElement element : elements) {
					if (element.getName().equals(ELEMENT_NAME_WIZARD)) {
						if (AbapCoreUi.PROJECT_WIZARD_ID.equals(element.getAttribute(ATTRIBUTE_NAME_ID))) {
							return element;
						}
					}
				}
			}
			return null;
		}

		IProject doShowNewWizard(IWizard wizard, Dialog dialog) {
			if (dialog.open() == Window.OK) {
				// only use Wizard in signature and downcast in implementation
				// to avoid API leakage
				return ((NewAbapProjectWizard) wizard).getProject();
			}
			return null;
		}
	}

	@Override
	public void run(final IIntroSite site, final Properties params) {
		HashSet<String> favoritePackages = new HashSet<String>();
		//favoritePackages.add("S_EPM"); //$NON-NLS-1$
		//favoritePackages.add("S_EPM_GATEWAY"); //$NON-NLS-1$
		//favoritePackages.add("S_NWDEMO_MODEL_DDIC"); //$NON-NLS-1$
		//favoritePackages.add("S_EPM_STAKEHOLDERS"); //$NON-NLS-1$
		favoritePackages.add("S_EPM_UX_PO"); //$NON-NLS-1$
		favoritePackages.add("S_EPM_UX_SO"); //$NON-NLS-1$
		favoritePackages.add("S_EPM_GATEWAY"); //$NON-NLS-1$
		favoritePackages.add("S_EPM_HANA"); //$NON-NLS-1$
		favoritePackages.add("S_EPM_OIA"); //$NON-NLS-1$

		ShowNewAbapProjectWizardRunnable runnable = new ShowNewAbapProjectWizardRunnable(favoritePackages);

		Display.getDefault().asyncExec(runnable);

	}
}
