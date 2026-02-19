"""Centralized logging configuration for Machine Config Parser."""

import logging
from colorama import init, Fore

# Initialize colorama for cross-platform colored terminal output
init(autoreset=True)


def configure_logger(name: str, level: int = logging.INFO) -> logging.Logger:
    """
    Configure and return a logger with standardized formatting.
    
    Args:
        name: Logger name (typically __name__)
        level: Logging level (default: INFO)
    
    Returns:
        Configured logger instance
    """
    logger = logging.getLogger(name)
    
    # Only configure if not already configured
    if not logger.handlers:
        logger.setLevel(level)
        
        # Create console handler with formatting
        handler = logging.StreamHandler()
        formatter = logging.Formatter(
            "%(asctime)s [%(levelname)-8s] %(name)s: %(message)s",
            datefmt="%Y-%m-%d %H:%M:%S"
        )
        handler.setFormatter(formatter)
        logger.addHandler(handler)
    
    return logger


def log_info(logger: logging.Logger, message: str) -> None:
    """Log an info message."""
    logger.info(f"{Fore.CYAN}{message}{Fore.RESET}")


def log_success(logger: logging.Logger, message: str) -> None:
    """Log a success message (green)."""
    logger.info(f"{Fore.GREEN}{message}{Fore.RESET}")


def log_warning(logger: logging.Logger, message: str) -> None:
    """Log a warning message (yellow)."""
    logger.warning(f"{Fore.YELLOW}{message}{Fore.RESET}")


def log_error(logger: logging.Logger, message: str) -> None:
    """Log an error message (red)."""
    logger.error(f"{Fore.RED}{message}{Fore.RESET}")


def log_exception(logger: logging.Logger, message: str, exc: Exception) -> None:
    """Log an exception with context."""
    logger.exception(f"{Fore.RED}{message}: {exc}{Fore.RESET}")
