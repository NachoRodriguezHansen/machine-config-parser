import pandas as pd
from pathlib import Path

from core.utils.convert_xml import convert_xml_to_csv


def test_convert_xml_to_csv(tmp_path: Path):
    xml_content = """
    <root>
      <record>
        <col1>1</col1>
        <col2>foo</col2>
      </record>
      <record>
        <col1>2</col1>
        <col2>bar</col2>
      </record>
    </root>
    """

    xml_file = tmp_path / "sample.xml"
    xml_file.write_text(xml_content, encoding="utf-8")

    csv_file = tmp_path / "out.csv"

    convert_xml_to_csv(xml_file, csv_file)

    assert csv_file.exists(), "CSV file was not created"

    df = pd.read_csv(csv_file, dtype=str)
    assert df.shape[0] == 2
    assert set(["col1", "col2"]).issubset(set(df.columns))
    assert df.iloc[0]["col1"] == "1"
    assert df.iloc[1]["col2"] == "bar"
