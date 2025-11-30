import streamlit as st

class AppStyles:

    def __init__(self):
        pass

    def style_tabs(self):
        st.markdown("""
            <style>
                /* Adjust margins and prevent text cutoff */
                .main .block-container {
                    padding-top: 10px;
                    padding-bottom: 10px;
                    padding-left: 20px;
                    padding-right: 20px;
                }

                /* Ensure header text does not get cut off */
                h1, h2, h3, h4, h5, h6 {
                    white-space: normal !important;
                    overflow-wrap: break-word !important;
                    word-break: break-word !important;
                }

                /* Ensure paragraphs also have appropriate size */
                p {
                    font-size: 25px !important;
                }
            </style>
        """, unsafe_allow_html=True)

    def style_buttons(self):
        st.markdown("""
            <style>
                /* Change button size */
                .stButton button {
                    font-size: 10px !important;  /* Larger font size */
                    padding: 15px 30px !important;  /* Increase button size */
                    border-radius: 10px !important;  /* Rounded corners (optional) */
                }
            </style>
        """, unsafe_allow_html=True)

    def style_selectboxes(self):
        st.markdown("""
            <style>
                /* Style all selectboxes and multiselects in sidebar */
                div[role="combobox"] > div:first-child {
                    border: 1px solid #888 !important;
                    border-radius: 5px !important;
                    background-color: #f0f0f0 !important;
                    cursor: pointer !important;
                }
                div[role="combobox"]:hover > div:first-child {
                    border: 1px solid #444 !important;
                }

                /* Optional: adjust font size inside selectbox */
                div[role="listbox"] {
                    font-size: 14px !important;
                }
            </style>
        """, unsafe_allow_html=True)
