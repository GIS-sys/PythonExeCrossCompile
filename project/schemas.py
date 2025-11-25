import uuid

class UniqueIdGenerator():
    def __init__(self):
        self.generated = set()

    def generate_uuid(self):
        while True:
            code = str(uuid.uuid4()).replace('-', '')[:8]
            if code not in self.generated:
                self.generated.add(code)
                return code



