See example scripts for usage.

Two callbacks are used, one to configure a row with the widgets, and
one to populate the data. Each displayed row's widgets are configured
with the configuration callback, and each row is populated with the
populate callback. When the region is scrolled, the populated data is
changed, and the widgets are left in place.

For basic scrolling areas, the configure callback is only executed on
initialization and when the window is resized.

Features:
   -  Set a number of lines as reserved. These lines will stay at the
      top of the display and not scroll (setReserved).
   -  Set the page overlap for the page up/down keys (setPageAdjust).
   -  Row 0 is reserved as a heading line.

2.12 2020-10-29
  Code cleanup
