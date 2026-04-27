#!/usr/bin/env bash
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#
HYPHEN_SYMBOL='-'

# Prevent debug mode from being enabled in production containers.
# The Werkzeug interactive debugger allows arbitrary code execution.
# Match all truthy values accepted by Python's parse_boolean_string().
FLASK_DEBUG_LOWER=$(echo "${FLASK_DEBUG}" | tr '[:upper:]' '[:lower:]')
if [ "${FLASK_DEBUG_LOWER}" = "1" ] || [ "${FLASK_DEBUG_LOWER}" = "true" ] || [ "${FLASK_DEBUG_LOWER}" = "t" ] || [ "${FLASK_DEBUG_LOWER}" = "yes" ] || [ "${FLASK_DEBUG_LOWER}" = "y" ] || [ "${FLASK_DEBUG_LOWER}" = "on" ]; then
    echo "FATAL: FLASK_DEBUG is enabled. The Werkzeug interactive debugger allows" >&2
    echo "arbitrary remote code execution. Refusing to start gunicorn." >&2
    echo "To fix: unset FLASK_DEBUG or set FLASK_DEBUG=0" >&2
    exit 1
fi

gunicorn \
    --bind "${SUPERSET_BIND_ADDRESS:-0.0.0.0}:${SUPERSET_PORT:-8088}" \
    --access-logfile "${ACCESS_LOG_FILE:-$HYPHEN_SYMBOL}" \
    --error-logfile "${ERROR_LOG_FILE:-$HYPHEN_SYMBOL}" \
    --workers ${SERVER_WORKER_AMOUNT:-1} \
    --worker-class ${SERVER_WORKER_CLASS:-gthread} \
    --threads ${SERVER_THREADS_AMOUNT:-20} \
    --log-level "${GUNICORN_LOGLEVEL:-info}" \
    --timeout ${GUNICORN_TIMEOUT:-60} \
    --keep-alive ${GUNICORN_KEEPALIVE:-2} \
    --max-requests ${WORKER_MAX_REQUESTS:-0} \
    --max-requests-jitter ${WORKER_MAX_REQUESTS_JITTER:-0} \
    --limit-request-line ${SERVER_LIMIT_REQUEST_LINE:-0} \
    --limit-request-field_size ${SERVER_LIMIT_REQUEST_FIELD_SIZE:-0} \
    "${FLASK_APP}"
