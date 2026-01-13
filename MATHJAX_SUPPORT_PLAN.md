# MathJax Support for LaTeX2HTML

## Problem Statement

When copy-pasting course pages into LLMs (Claude, ChatGPT, etc.), equation images are omitted and the ALT text containing LaTeX source is not provided as a substitute. This breaks LLM context for advanced mathematical material.

## Current Flow

```
LaTeX math → DVI → PostScript → PNG/GIF → <img alt="LaTeX source">
```

The ALT text contains the LaTeX source, but browsers/LLMs don't include it when copying.

## Target Flow

```
LaTeX math → MathJax delimiters \(...\) or \[...\] → browser renders via MathJax
```

## Benefits

- **LLM-friendly**: Equations copy-paste correctly with LaTeX source preserved
- **Responsive**: MathJax scales properly on all devices
- **Accessible**: Screen readers can interpret equations, zoom works
- **Faster**: No image files to load
- **Searchable**: Equation text is part of the DOM

## Key Files to Modify

| File | Purpose | Lines |
|------|---------|-------|
| `latex2html.pin` | Main script, `embed_image()` generates IMG tags | ~17K |
| `versions/math.pl` | Math environment detection and processing | ~2.6K |
| `styles/amsmath.perl` | AMS math support | ~21K |
| `styles/more_amsmath.perl` | Advanced AMS environments | ~33K |
| `l2hconf.pin` | Configuration template | ~1K |

## Implementation Plan

### Phase 1: Configuration

Add to `l2hconf.pin`:
```perl
# MathJax support (set to 1 to use MathJax instead of images for math)
$USE_MATHJAX = 1;

# MathJax CDN URL (or path to local installation)
$MATHJAX_URL = 'https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js';

# MathJax inline delimiters
$MATHJAX_INLINE_OPEN = '\\(';
$MATHJAX_INLINE_CLOSE = '\\)';

# MathJax display delimiters
$MATHJAX_DISPLAY_OPEN = '\\[';
$MATHJAX_DISPLAY_CLOSE = '\\]';
```

### Phase 2: HTML Head Injection

Modify HTML generation to include MathJax loader when `$USE_MATHJAX` is enabled.

Add to document `<head>`:
```html
<script>
MathJax = {
  tex: {
    inlineMath: [['\\(', '\\)']],
    displayMath: [['\\[', '\\]']],
    processEscapes: true,
    processEnvironments: true
  },
  options: {
    skipHtmlTags: ['script', 'noscript', 'style', 'textarea', 'pre']
  }
};
</script>
<script src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js" async></script>
```

### Phase 3: Modify embed_image()

In `latex2html.pin`, the `embed_image()` function (lines 9933-10110) generates IMG tags.

When `$USE_MATHJAX` is enabled and the image is for math:
- Instead of `<IMG SRC="img123.png" ALT="$x^2$">`
- Output `\(x^2\)` for inline math
- Output `\[x^2\]` for display math

Key decision point: The ALT text already contains the LaTeX source, so we can extract it.

### Phase 4: Math Environment Handling

In `versions/math.pl`, modify math environment processors:

- `do_env_math()` - inline math
- `do_env_displaymath()` - display math
- `do_env_equation()` - numbered equations
- `do_env_eqnarray()` - equation arrays
- `do_env_align()` - aligned equations

For each, when `$USE_MATHJAX`:
- Skip image generation
- Output LaTeX source wrapped in appropriate delimiters
- Handle equation numbering separately (MathJax can auto-number)

### Phase 5: AMS Package Support

The `styles/amsmath.perl` and `more_amsmath.perl` files handle:
- `align`, `align*`
- `gather`, `gather*`
- `multline`, `multline*`
- `split`
- `cases`
- `matrix`, `pmatrix`, `bmatrix`, etc.

Each needs a MathJax code path that outputs the raw LaTeX.

### Phase 6: Testing

Test with all math environments:
```latex
% Inline
$x^2 + y^2 = z^2$

% Display
\[ \int_0^\infty e^{-x^2} dx = \frac{\sqrt{\pi}}{2} \]

% Equation with number
\begin{equation}
E = mc^2
\end{equation}

% Align
\begin{align}
a &= b + c \\
d &= e + f
\end{align}

% Matrix
\begin{pmatrix} a & b \\ c & d \end{pmatrix}

% Cases
f(x) = \begin{cases} 1 & x > 0 \\ 0 & x \leq 0 \end{cases}
```

### Phase 7: Rollout

1. Test on one book (mdft - smallest)
2. Verify rendering matches images
3. Test copy-paste into Claude
4. Roll out to filters, pasp, sasp

## Fallback Strategy

Keep `$USE_MATHJAX = 0` option to fall back to image generation for:
- Print/PDF output
- Environments where MathJax isn't available
- Debugging rendering issues

## Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| MathJax CDN unavailable | Option for local MathJax installation |
| Complex equations render differently | Side-by-side comparison testing |
| Page load delay | MathJax async loading, show placeholder |
| Old browser support | MathJax 3 supports modern browsers; fallback to images |

## Success Criteria

1. All equations render correctly in browser
2. Copy-paste into Claude preserves LaTeX source
3. No visual regression from current image-based rendering
4. Page load time acceptable (< 2s additional)

## References

- [MathJax Documentation](https://docs.mathjax.org/en/latest/)
- [MathJax Configuration Options](https://docs.mathjax.org/en/latest/options/index.html)
- [LaTeX2HTML Source](https://github.com/latex2html/latex2html)
