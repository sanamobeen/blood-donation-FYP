"""
Logging filter to reduce noise from expected client disconnections.
"""
import logging


class IgnoreBrokenPipeFilter(logging.Filter):
    """
    Filter to downgrade or ignore broken pipe and client disconnect messages.
    These are expected when users close the app or navigate away during requests.
    """

    def filter(self, record):
        # Downgrade broken pipe messages to DEBUG level
        message = record.getMessage().lower()

        broken_pipe_indicators = [
            'broken pipe',
            'connection reset by peer',
            'client closed connection',
        ]

        for indicator in broken_pipe_indicators:
            if indicator in message:
                record.levelno = logging.DEBUG
                record.levelname = 'DEBUG'
                break

        return True
