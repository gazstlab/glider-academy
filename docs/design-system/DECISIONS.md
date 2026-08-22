# Design decision record

One row per decision. Format: `date · what · why · what was discarded`.
Every exception to the design system rules **must** appear here, or it is a bug.

| Date | Decision | Reason | Discarded |
|---|---|---|---|
| 2026-08-22 | D1 · Sectional aeronautical chart as the visual language | The product is route navigation (DAGs); a chart is the native artefact of that world and avoids the generic SaaS dashboard look | Dark theme with a single neon accent; newspaper layout with a serif |
| 2026-08-22 | D2 · Dark as the default, light as the alternative | People spend most of their time in an editor and a terminal; the lab sets the theme, not the landing page | Light by default with dark optional |
| 2026-08-22 | D3 · Cold chart paper (`#EDF1F5`) in light mode | Warm cream is the default background of every AI-generated site today; cold keeps the printed-chart reading | `#F4F1EA` and neighbours |
| 2026-08-22 | D4 · No diffuse shadows; depth by hairline | A navigation instrument is drawn with lines, not with volume | Layered elevation with `box-shadow` |
| 2026-08-22 | D5 · Archivo with width axis 112 for display | Gives the proportion of a panel label; variable width is a signed choice and cannot be faked with tracking | Space Grotesk, Inter Display |
| 2026-08-22 | D6 · A single ambient animation (the dashed running edge) | Motion exists to say "this is running right now"; any other effect dilutes that signal | Scroll reveal, counters, parallax |
| 2026-08-22 | D7 · Progress as altitude (`Altimeter`), not a % bar | A bar says how much is left; an altimeter also says where you started, which is the point of the product | Progress bar, circular ring |
| 2026-08-22 | D8 · Task state requires colour + shape + text | Reading the DAG's state is the central task; it cannot depend on colour perception | Colour alone, as in the original Airflow |
| 2026-08-22 | D9 · Below 900px the lab has no editable canvas | Three panels on a phone is not usable; the mobile version is read plus run | Panels collapsed into tabs on mobile |
| 2026-08-22 | D10 · The glider metaphor lives in the vocabulary, not in illustration | A repeated reference becomes a mascot and ages fast | Glider illustrations per section |
| 2026-08-22 | D11 · **Supersedes D1** · The visual language descends from the Apache Airflow UI, not from an aeronautical chart | Transfer is the product: whoever finishes Glider needs to recognise a real Airflow in the first second | Sectional aeronautical chart (beautiful, but foreign to the tool's domain) |
| 2026-08-22 | D12 · **Supersedes D2 and D3** · Light is the default theme; dark is first class | The Airflow UI is light by default; Glider inherits that so the switch does not feel foreign | Dark by default |
| 2026-08-22 | D13 · **Supersedes D6 and D7** · The signature is the state grid; progress is a grid column | The grid view is Airflow's most recognisable visual and works simultaneously as progress and as lesson content | Dashed Bézier route; vertical altimeter |
| 2026-08-22 | D14 · State colours inherited by hue from `airflow.utils.state`, retuned by value | Airflow's CSS named colours fail contrast; keeping the hue preserves recognition and the retune fixes accessibility | Adopting the named colours verbatim; inventing our own palette |
| 2026-08-22 | D15 · Brand blue (`#017CEE`) is forbidden as a state colour | In Airflow blue is identity, not status; mixing them destroys the grid's readability | Using the blue as the `none` state |
| 2026-08-22 | D16 · **Supersedes D5** · Inter for body (the Airflow UI's font), Familjen Grotesk for display | Familiarity is the point; personality stays in the display so the site does not become a visual fork of Airflow | Expanded Archivo; Space Grotesk |
| 2026-08-22 | D17 · **Supersedes D4** · Light shadows allowed (`card`, `pop`) and a 6px radius on controls | Aligns with the Chakra of the Airflow 3 UI; the hairline rule came from the previous direction | Keeping pure hairline and sharp corners |
| 2026-08-22 | D18 · No state outside `airflow.utils.state` may exist in the UI | An invented state teaches something false, which is the worst possible defect in a teaching product | Our own didactic states ("almost there", "attention") |
