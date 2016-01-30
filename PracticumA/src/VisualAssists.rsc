module VisualAssists

import vis::Figure;

// import data types used in metrics
import MetricsGrading;

// Creates in a uniform way the popup
// That is used in the application
// The text is profived in a VIS text object
public FProperty PopupBox(Figure text, FProperty allignment)
{
	return mouseOver(box(text, fillColor("lightyellow"), grow(1.2), resizable(false), allignment));
}


