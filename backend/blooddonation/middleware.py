"""
Custom middleware to handle common connection errors gracefully.
"""
import logging
from django.http import HttpResponse
from django.utils.deprecation import MiddlewareMixin

logger = logging.getLogger(__name__)


class HandleConnectionErrorsMiddleware(MiddlewareMixin):
    """
    Handles common connection errors like Broken Pipe without raising exceptions.
    This prevents cluttering logs with expected client disconnections.
    """

    def process_exception(self, request, exception):
        # Handle client disconnecting before response completes
        error_message = str(exception).lower()

        if 'broken pipe' in error_message or \
           'connection reset by peer' in error_message or \
           'client closed connection' in error_message:

            # Log at debug level instead of error since this is expected behavior
            logger.debug(
                f"Client disconnected during {request.method} {request.path}: "
                f"IP={request.META.get('REMOTE_ADDR')}"
            )
            # Return None to let Django handle the closed connection
            return None

        return None  # Let other exceptions propagate normally
