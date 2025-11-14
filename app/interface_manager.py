import streamlit as st
from tabs_manager import Tabs
from style_manager import AppStyles

class Interface:

    def __init__(self):
        st.set_page_config(page_title="Machine config app", layout="wide")
        styles = AppStyles()
        styles.style_tabs()
        styles.style_buttons()
        self.machine_w = 'Wxxx'
        self.machine_t = 'T300'

    def sidebar_configuration(self):
        st.sidebar.title('Machine Type:')

        col1, col2 = st.sidebar.columns(2)
        with col1:
            self.w5xx_button = st.button('W5xx')
        with col2:
            self.t30x_button = st.button('T30x')

        if self.w5xx_button:
            st.session_state.machine_type = self.machine_w
        elif self.t30x_button:
            st.session_state.machine_type = self.machine_t

    def show_buttons(self):
        if  'machine_type' in st.session_state:
            selected_machine = st.session_state.machine_type
            w_tabs = Tabs(selected_machine)
            w_tabs.create_tabs()
