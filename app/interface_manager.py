import streamlit as st
from tabs_manager import Tabs
from style_manager import AppStyles
from py.utilities.series_definitions import get_supported_series


class Interface:

    def __init__(self):
        # Configure Streamlit page
        st.set_page_config(page_title="Machine config app", layout="wide")

        # Apply custom styles
        styles = AppStyles()
        styles.style_tabs()
        styles.style_buttons()

        # Load supported machine series dynamically
        # Example: ["W500", "W540", "T300", "T305", ...]
        self.machines = get_supported_series()

    def sidebar_configuration(self):
        st.sidebar.title("Machine Type:")

        # Create buttons dynamically based on the available series
        for series in self.machines:
            # Display a button for each series
            if st.sidebar.button(series):
                # Save selected machine in Streamlit session state
                st.session_state.machine_type = series

        # Optional: show what is selected
        if "machine_type" in st.session_state:
            st.sidebar.markdown(f"**Selected:** {st.session_state.machine_type}")

    def show_buttons(self):
        # Only show tabs if a machine type has been selected
        if "machine_type" in st.session_state:
            selected_machine = st.session_state.machine_type

            # Create tabs for the selected machine
            w_tabs = Tabs(selected_machine)
            w_tabs.create_tabs()
