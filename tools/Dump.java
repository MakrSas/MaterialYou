import android.util.Pair;
import com.android.systemui.monet.DynamicColors;
import com.google.ux.material.libmonet.dynamiccolor.*;
import com.google.ux.material.libmonet.dynamiccolor.ColorSpec.SpecVersion;
import com.google.ux.material.libmonet.hct.Hct;
import com.google.ux.material.libmonet.scheme.*;
import com.google.ux.material.libmonet.quantize.QuantizerCelebi;
import com.google.ux.material.libmonet.score.Score;
import java.util.*;

// Reference dump for the iOS port (LineageQS/Monet). One line per value:
// case<TAB>style<TAB>dark<TAB>token<TAB>#AARRGGBB
public class Dump {
  static int[][] SEEDS = {
    {0xFF1B6EF3}, {0xFF6750A4}, {0xFFB3261E}, {0xFF00A86B}, {0xFFFFC107}, {0xFF808080}, {0xFF2E7D32, 0xFFF06292},
    {0xFF0D47A1, 0xFFFF7043, 0xFF26A69A}, {0xFFE91E63}, {0xFF795548}, {0xFF00BCD4}, {0xFF9C27B0}, {0xFF101010}, {0xFFF5F5F5}
  };
  static String[] STYLES = {"neutral", "tonal_spot", "vibrant", "expressive"};

  static DynamicScheme scheme(String style, List<Hct> seeds, boolean dark) {
    SpecVersion v = SpecVersion.SPEC_2026;
    DynamicScheme.Platform p = DynamicScheme.Platform.PHONE;
    switch (style) {
      case "neutral": return new SchemeNeutral(seeds, dark, 0.0, v, p);
      case "tonal_spot": return new SchemeTonalSpot(seeds, dark, 0.0, v, p);
      case "vibrant": return new SchemeVibrant(seeds, dark, 0.0, v, p);
      default: return new SchemeExpressive(seeds, dark, 0.0, v, p);
    }
  }

  public static void main(String[] a) {
    List<Pair<String, DynamicColor>> all = new ArrayList<>();
    all.addAll(DynamicColors.getAllDynamicColorsMapped());
    all.addAll(DynamicColors.getFixedColorsMapped());
    all.addAll(DynamicColors.getCustomColorsMapped());
    all.addAll(DynamicColors.getAllAccentPalette());
    all.addAll(DynamicColors.getAllNeutralPalette());
    all.addAll(DynamicColors.getAllErrorPalette());
    StringBuilder out = new StringBuilder();
    for (int i = 0; i < SEEDS.length; i++) {
      List<Hct> seeds = new ArrayList<>();
      for (int s : SEEDS[i]) seeds.add(Hct.fromInt(s));
      for (String st : STYLES) for (int d = 0; d < 2; d++) {
        DynamicScheme sc = scheme(st, seeds, d == 1);
        for (Pair<String, DynamicColor> e : all)
          out.append(i).append('\t').append(st).append('\t').append(d).append('\t').append(e.first).append('\t')
             .append(String.format("#%08X", e.second.getArgb(sc))).append('\n');
      }
    }
    // Quantizer + score on deterministic pseudo-random "wallpapers".
    for (int img = 0; img < 4; img++) {
      long x = 12345 + img * 777;
      int[] px = new int[128 * 128];
      int base = SEEDS[img * 3][0];
      for (int k = 0; k < px.length; k++) {
        x = (x * 6364136223846793005L + 1442695040888963407L);
        int r = (int) ((x >>> 33) & 0xff), g = (int) ((x >>> 41) & 0xff), b = (int) ((x >>> 49) & 0xff);
        if ((k / 128) < 80) { r = ((base >> 16) & 0xff) * 3 / 4 + r / 4; g = ((base >> 8) & 0xff) * 3 / 4 + g / 4; b = (base & 0xff) * 3 / 4 + b / 4; }
        px[k] = 0xFF000000 | (r << 16) | (g << 8) | b;
      }
      Map<Integer, Integer> q = QuantizerCelebi.quantize(px, 128);
      List<Integer> sc = Score.score(q);
      StringBuilder s = new StringBuilder();
      for (int c : sc) s.append(String.format("#%08X ", c));
      out.append("score\t").append(img).append("\t-\t-\t").append(s.toString().trim()).append('\n');
    }
    System.out.print(out);
  }
}
