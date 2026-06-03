# 1단계: 가볍고 안정적인 Python 공식 Slim 이미지를 베이스 이미지로 사용
FROM python:3.14-slim

# 환경 변수 설정
# PYTHONDONTWRITEBYTECODE: .pyc 파일을 디스크에 쓰지 않도록 설정 (용량 절약 및 깔끔한 유지)
# PYTHONUNBUFFERED: 버퍼링 없이 즉시 로그를 출력하도록 설정 (도커 컨테이너 로그 모니터링에 필수)
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8000

# 작업 디렉터리 설정
WORKDIR /app

# 시스템 의존성 설치 (필요시 컴파일러 등 추가, slim 버전 기본 번들 유지)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# requirements.txt 레이어 캐싱을 위해 의존성 파일만 먼저 복사 및 설치
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# 애플리케이션 소스 코드 복사
COPY ./app ./app

# 비루트(Non-root) 사용자 생성 및 권한 부여 (보안 강화 권장사항)
RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser

# 외부 노출 포트 설정
EXPOSE ${PORT}

# Gunicorn을 실행하여 Uvicorn 비동기 워커를 관리하도록 명령어 실행
# --workers: CPU 코어 수 등에 맞게 조정 (일반적으로 CPU 코어 수 * 2 + 1 공식 사용)
# -k uvicorn.workers.UvicornWorker: Gunicorn이 사용할 비동기 ASGI 워커 지정
CMD ["gunicorn", \
     "app.main:app", \
     "--workers", "4", \
     "--worker-class", "uvicorn.workers.UvicornWorker", \
     "--bind", "0.0.0.0:8000", \
     "--access-logfile", "-", \
     "--error-logfile", "-"]