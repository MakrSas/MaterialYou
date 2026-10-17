import android.util.Pair;
import com.android.systemui.monet.DynamicColors;
import com.google.ux.material.libmonet.dynamiccolor.*;
import com.google.ux.material.libmonet.dynamiccolor.ColorSpec.SpecVersion;
import com.google.ux.material.libmonet.hct.Hct;
import com.google.ux.material.libmonet.scheme.*;
import java.io.*;
import java.util.*;

// Table for LineageQS: [style 4][hue 360][dark 2][token N] uint32 little-endian ARGB.
// seed = Hct.from(hue, 100, 80) (ThemePicker freeform), SPEC_2026, PHONE, contrast 0.
public class Gen {
  public static void main(String[] a) throws Exception {
    List<Pair<String, DynamicColor>> all = new ArrayList<>();
    all.addAll(DynamicColors.getAllDynamicColorsMapped());
    all.addAll(DynamicColors.getFixedColorsMapped());
    all.addAll(DynamicColors.getCustomColorsMapped());
    all.addAll(DynamicColors.getAllAccentPalette());
    all.addAll(DynamicColors.getAllNeutralPalette());
    all.addAll(DynamicColors.getAllErrorPalette());
    String[] styles = {"neutral", "tonal_spot", "vibrant", "expressive"};
    try (PrintWriter names = new PrintWriter("monet_tokens.txt")) {
      for (Pair<String, DynamicColor> e : all) names.println(e.first);
      names.println("swatch"); // accent1 s450 light / s200 dark (ColorProviderUtil)
    }
    DataOutputStream out = new DataOutputStream(new BufferedOutputStream(new FileOutputStream("monet_table.bin")));
    SpecVersion v = SpecVersion.SPEC_2026; DynamicScheme.Platform p = DynamicScheme.Platform.PHONE;
    for (String st : styles) for (int h = 0; h < 360; h++) for (int d = 0; d < 2; d++) {
      List<Hct> seeds = List.of(Hct.fromInt(Hct.from(h, 100, 80).toInt()));
      boolean dark = d == 1;
      DynamicScheme s = switch (st) {
        case "neutral" -> new SchemeNeutral(seeds, dark, 0.0, v, p);
        case "tonal_spot" -> new SchemeTonalSpot(seeds, dark, 0.0, v, p);
        case "vibrant" -> new SchemeVibrant(seeds, dark, 0.0, v, p);
        default -> new SchemeExpressive(seeds, dark, 0.0, v, p);
      };
      for (Pair<String, DynamicColor> e : all) out.writeInt(Integer.reverseBytes(e.second.getArgb(s)));
      out.writeInt(Integer.reverseBytes(s.primaryPalette.tone(dark ? 80 : 55)));
    }
    out.close();
  }
}
