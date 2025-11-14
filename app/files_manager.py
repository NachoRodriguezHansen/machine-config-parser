import streamlit as st
import pandas as pd
from pathlib import Path


class Files:

    def __init__(self, machine):
        self.machine = machine
        self.folder = Path(__file__).parent.parent / "py" / "outfiles"
        if not self.folder.exists():
            raise FileNotFoundError(f"Folder not found: {self.folder}")
        self.correct_file = None
        self.df = pd.DataFrame()

    def find_csv(self):
        """Find the CSV file matching the machine series."""
        csv_files = list(self.folder.glob(f"{self.machine}_*.csv"))
        if not csv_files:
            st.warning(f"No CSV file found for machine '{self.machine}' in {self.folder}")
            return

        # Take the first match
        self.correct_file = csv_files[0]

    def show_data(self):
        """Load CSV into a DataFrame and store in session_state."""
        df_key = f"df_{self.machine}"

        if self.correct_file is None:
            st.warning(f"No CSV file selected for machine '{self.machine}'")
            return

        # Load the DataFrame only if not already in session_state
        if df_key not in st.session_state:
            self.df = pd.read_csv(self.correct_file, sep=',', dtype=str)
            st.session_state[df_key] = self.df

        self.df = st.session_state[df_key]

    def show_filtered_data(self):
        """Display DataFrame with optional column filtering."""
        df_key = f"df_{self.machine}"
        election_key = f"election_{self.machine}"

        if df_key not in st.session_state:
            st.warning('No data loaded')
            return

        self.df = st.session_state[df_key]

        # Sidebar to select columns
        st.sidebar.multiselect(
            'Choose columns',
            self.df.columns.tolist(),
            key=election_key
        )

        # Get selected columns from session_state
        selected_columns = st.session_state.get(election_key, self.df.columns.tolist())

        # Display the DataFrame with the selected columns
        if selected_columns:
            st.data_editor(self.df[selected_columns], use_container_width=True, hide_index=True)
        else:
            st.data_editor(self.df, use_container_width=True, hide_index=True)
