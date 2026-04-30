FROM getconvoy/mintlify-previewer:latest

WORKDIR /app
COPY . .

RUN npm i -g mint
ENTRYPOINT [ "mint", "dev" ]