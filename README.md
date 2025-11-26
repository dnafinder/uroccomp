[![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/github/v1?repo=dnafinder/uroccomp&file=uroccomp.m)

# uroccomp

## 📌 Overview

uroccomp compares two unpaired ROC curves obtained from two independent datasets. Each dataset must contain a continuous or ordinal diagnostic test value and a binary outcome (healthy vs diseased).

The function

- computes ROC curves for both datasets by calling roc
- extracts the Area Under the Curve (AUC) and its standard error (SE) for each ROC
- performs a z test for the difference between the two AUCs
- prints a summary table with AUC and SE for each ROC
- prints the z value and two sided p value for the comparison
- plots both ROC curves on the same graph for visual comparison

It is designed for classical diagnostic test studies where two independent tests or markers are compared in terms of their discriminative ability.

---

## 📐 Syntax

The main calling forms are

- uroccomp(X, Y)
- uroccomp(X, Y, ALPHA)

If no output argument is requested, the function prints numeric results in the Command Window and displays a comparison plot of the two ROC curves.

---

## 📥 Inputs

### X

- Type  numeric matrix, size N1 by 2
- Columns
  - X(:,1)  test values (real, finite, non NaN, non empty)
  - X(:,2)  binary class labels
    - 1  unhealthy or diseased
    - 0  healthy or non diseased

All values in X(:,2) must be either 0 or 1.  
If all labels in X(:,2) are 0 (only healthy) or all are 1 (only unhealthy), the function throws an error.

---

### Y

- Type  numeric matrix, size N2 by 2
- Columns
  - Y(:,1)  test values
  - Y(:,2)  binary class labels
    - 1  unhealthy or diseased
    - 0  healthy or non diseased

All values in Y(:,2) must be either 0 or 1.  
If all labels in Y(:,2) are 0 (only healthy) or all are 1 (only unhealthy), the function throws an error.

---

### ALPHA (optional)

- Significance level for the z test comparing the two AUCs
- Default value  0.05
- Must satisfy  0 < ALPHA < 1

The p value is computed for a two sided test:

- H0  AUC1 equals AUC2
- H1  AUC1 different from AUC2

If ALPHA is not specified, the default 0.05 is used.

---

## 📤 Outputs

uroccomp does not return an output argument. Instead, it

- prints a table with AUC and standard error for each ROC curve
- prints the z value and p value for the difference between AUCs
- prints a comment indicating if the areas are statistically different at the chosen ALPHA level
- generates a figure showing both ROC curves and the diagonal chance line

The printed tables have the form

- First table
  - Rows  AUC, Standard_error
  - Columns  ROC1, ROC2
- Second table
  - Columns  z_value, p_value, Comment

---

## 📊 Example

Suppose you have two independent diagnostic tests measured on different groups of subjects. Each matrix has two columns  test result and class label (1 diseased, 0 healthy).

Example usage

- Basic comparison using default alpha 0.05

  uroccomp(X, Y);

- Comparison with a stricter significance level alpha 0.01

  uroccomp(X, Y, 0.01);

The function will

- compute two ROC curves via roc
- show the AUC and SE for ROC1 and ROC2
- report the z statistic and two sided p value
- report whether the difference in AUC is statistically significant at the chosen alpha
- show both ROC curves in the same plot, together with the line of no discrimination

---

## 🧠 Method

1. ROC computation

   uroccomp calls roc separately on X and Y with

   - threshold set to 0 (use all unique positive values as candidate cut offs)
   - alpha equal to the ALPHA argument
   - no textual output and no plots (verbose equal to 0, plotting equal to 0)

   For each dataset, roc returns

   - AUC and its standard error SE
   - ROC coordinates xr and yr

2. AUC extraction

   The areas under the curves and their standard errors are extracted from the two structs returned by roc

   - AUC1, SE1 for dataset X
   - AUC2, SE2 for dataset Y

3. Comparison of AUCs

   The difference between the two AUCs is tested using a z statistic based on the standard errors, assuming the two ROC curves arise from independent samples. The test statistic is

   z = abs(AUC1 − AUC2) divided by sqrt(SE1 squared plus SE2 squared)

   The two sided p value is then computed from the standard normal distribution. If p is less than or equal to ALPHA, the two areas are considered statistically different.

4. Output tables

   The function prints

   - a table with AUC and standard error for ROC1 and ROC2
   - a table with z value, p value and a short comment indicating whether the areas are statistically different or not at the chosen ALPHA

5. ROC curves plot

   Finally, uroccomp plots

   - ROC curve 1 as a red stairs curve
   - ROC curve 2 as a blue stairs curve
   - the diagonal 45 degree line representing random classification

   The axes are square and the legend identifies the two ROC curves. The x axis is the false positive rate (1 minus specificity) and the y axis is the true positive rate (sensitivity).

---

## 📦 Requirements

- MATLAB (tested on recent releases)
- Core functions used
  - inputParser, validateattributes
  - repmat, realsqrt, erfc
  - array2table
  - stairs, plot, legend, axis, grid

- Dependencies

  uroccomp depends on

  - roc.m for computing each ROC curve
    - Repository  https://github.com/dnafinder/roc

  roc in turn depends on

  - mwwtest.m (Mann Whitney Wilcoxon test)
    - Repository  https://github.com/dnafinder/mwwtest

These functions must be on the MATLAB path before calling uroccomp.

---

## 📚 References

- Cardillo G. uROCcomp  compare two unpaired ROC curves.
- Hanley JA, McNeil BJ. The meaning and use of the area under a ROC curve. Radiology. 1982 143(1) 29 36.
- Metz CE. Basic principles of ROC analysis. Seminars in Nuclear Medicine. 1978 8(4) 283 298.

---

## 🧾 Citation

If you use this function in scientific or technical work, you may cite

Cardillo G. uROCcomp  compare two unpaired ROC curves. GitHub repository dnafinder/uroccomp.

You may also acknowledge the associated ROC and MWWTEST repositories

- dnafinder/roc
- dnafinder/mwwtest

---

## 👤 Author and Versioning

- Author  Giuseppe Cardillo
- Email  giuseppe.cardillo.75@gmail.com
- GitHub  https://github.com/dnafinder/uroccomp

Version history

- 1.0.0 (2009)  Initial implementation of unpaired ROC curve comparison.
- 2.0.0 (2025 11 26)  Modernized input validation, removed legacy automatic download from external sources, added explicit dependency check on roc, aligned documentation and style to the current GitHub ecosystem, and updated plotting to use the new roc outputs.
