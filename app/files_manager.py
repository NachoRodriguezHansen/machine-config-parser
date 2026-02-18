import streamlit as st
import pandas as pd
from pathlib import Path
import logging

logger = logging.getLogger(__name__)

class Files:
    def __init__(self, machine: str):
        from core.utils.definitions import DEFAULT_OUTFILES_PATH
        self.machine = machine
        self.base_folder = Path(__file__).parent.parent / DEFAULT_OUTFILES_PATH
        self.correct_file: Path | None = None
        self.df = pd.DataFrame()

    def find_csv(self):
        try:
            from core.utils.definitions import get_series_info
            series_info = get_series_info(self.machine)
            expected_csv_path = self.base_folder / Path(series_info.out_file_name).with_suffix(".csv")
            if expected_csv_path.exists():
                self.correct_file = expected_csv_path
            else:
                self.correct_file = None
        except Exception as exc:
            logger.debug("find_csv error for %s: %s", self.machine, exc)
            self.correct_file = None
        
    def show_data(self):
        if self.correct_file is None:
            self.find_csv()

        if self.correct_file is None:
            # Full-page friendly error
            st.markdown(
                f"""
                <div style="
                    display:flex;
                    justify-content:center;
                    align-items:center;
                    height:70vh;
                    flex-direction:column;
                    text-align:center;
                    color:#ff4b4b;
                ">
                    <h1 style="font-size:60px;">❌ CSV File Not Found</h1>
                    <p style="font-size:24px;">Machine: <b>{self.machine}</b></p>
                    <p style="font-size:20px;">Expected path: <i>{self.base_folder}</i></p>
                    <p style="font-size:18px;">Please ensure the CSV file is generated and located in the correct folder.</p>
                </div>
                """,
                unsafe_allow_html=True
            )
            return

        df_key = f"df_{self.machine}"
        if df_key not in st.session_state:
            try:
                self.df = pd.read_csv(self.correct_file, sep=",", dtype=str)
                st.session_state[df_key] = self.df
            except Exception as exc:
                logger.exception("Error reading CSV %s: %s", self.correct_file, exc)
                st.error(f"Error cargando CSV: {exc}")
                self.df = pd.DataFrame()
                st.session_state[df_key] = self.df

        self.df = st.session_state[df_key]


    def show_filtered_data(self):
        if self.df.empty:
            st.warning("No data loaded")
            return
        
        df_key = f"df_{self.machine}"
        election_key = f"election_{self.machine}"

        st.sidebar.multiselect(
                    "Choose columns",
                    self.df.columns.tolist(),
                    key=election_key
                )

        selected_columns = st.session_state.get(election_key, self.df.columns.tolist())

        if selected_columns:
            st.data_editor(self.df[selected_columns], use_container_width=True, hide_index=True)
        else:
            st.data_editor(self.df, use_container_width=True, hide_index=True)