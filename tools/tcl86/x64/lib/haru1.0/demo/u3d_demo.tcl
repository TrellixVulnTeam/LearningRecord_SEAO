# Copyright (c) 2022 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE for details.
# no demo for this... in libharu
# below mine

set demodir [file dirname [info script]]
lappend auto_path [file dirname $demodir]

package require haru

set pdf [HPDF_New]

set page [HPDF_AddPage $pdf]
HPDF_Page_SetWidth $page 600
HPDF_Page_SetHeight $page 600

# load 3d file
set u3d [HPDF_LoadU3DFromFile $pdf [file join $demodir u3d animal.u3d]]
set rect1 {left 0 bottom 0 right 600 top 600}

set annot [HPDF_Page_Create3DAnnot $page $rect1 $u3d]

# save the document to a file
set pdffilename [file rootname [file tail [info script]]]
HPDF_SaveToFile $pdf [file join [file dirname [info script]] pdf ${pdffilename}.pdf]
HPDF_Free $pdf
